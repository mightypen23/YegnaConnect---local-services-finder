require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { Client } = require('pg');

const local = new Client({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: String(process.env.DB_PASSWORD || '')
});
const neonUrl = process.env.NEON_DATABASE_URL || process.env.DATABASE_URL;
const neon = new Client({ connectionString: neonUrl });

function quoteIdent(value) {
  return `"${String(value).replace(/"/g, '""')}"`;
}

async function tableNames(client) {
  const result = await client.query(`select table_name from information_schema.tables
    where table_schema='public' and table_type='BASE TABLE' order by table_name`);
  return result.rows.map((row) => row.table_name);
}

async function main() {
  if (!neonUrl) throw new Error('NEON_DATABASE_URL or DATABASE_URL is required');
  await local.connect();
  await neon.connect();

  const destinationTables = await tableNames(neon);
  if (destinationTables.length > 0) {
    throw new Error(`Neon destination is not empty (${destinationTables.join(', ')}). Migration stopped to protect existing data.`);
  }

  const schema = await local.query(`
    select table_name, column_name, data_type, udt_name, is_nullable, column_default,
           character_maximum_length, numeric_precision, numeric_scale
    from information_schema.columns where table_schema='public'
    order by table_name, ordinal_position
  `);
  const tables = [...new Set(schema.rows.map((row) => row.table_name))];

  await neon.query('begin');
  try {
    // Create enum types used by the source schema.
    const enums = await local.query(`select t.typname, e.enumlabel from pg_type t
      join pg_enum e on t.oid=e.enumtypid join pg_namespace n on n.oid=t.typnamespace
      where n.nspname='public' order by t.typname, e.enumsortorder`);
    const groupedEnums = Map.groupBy(enums.rows, (row) => row.typname);
    for (const [name, values] of groupedEnums) {
      await neon.query(`create type ${quoteIdent(name)} as enum (${values.map((v) => `'${v.enumlabel.replace(/'/g, "''")}'`).join(', ')})`);
    }

    for (const table of tables) {
      const columns = schema.rows.filter((row) => row.table_name === table);
      const primary = await local.query(`select a.attname as column_name from pg_index i
        join pg_attribute a on a.attrelid=i.indrelid and a.attnum=any(i.indkey)
        where i.indrelid=$1::regclass and i.indisprimary`, [`public.${table}`]);
      const definitions = columns.map((column) => {
        let type;
        if (column.data_type === 'USER-DEFINED') type = quoteIdent(column.udt_name);
        else if (column.data_type === 'character varying') type = `varchar${column.character_maximum_length ? `(${column.character_maximum_length})` : ''}`;
        else if (column.data_type === 'numeric') type = `numeric${column.numeric_precision ? `(${column.numeric_precision},${column.numeric_scale || 0})` : ''}`;
        else type = column.data_type;
        const nullable = column.is_nullable === 'NO' ? ' not null' : '';
        const fallback = column.column_default ? ` default ${column.column_default}` : '';
        return `${quoteIdent(column.column_name)} ${type}${nullable}${fallback}`;
      });
      if (primary.rows.length) definitions.push(`primary key (${primary.rows.map((r) => quoteIdent(r.column_name)).join(', ')})`);
      await neon.query(`create table ${quoteIdent(table)} (${definitions.join(', ')})`);
    }

    for (const table of tables) {
      const rows = await local.query(`select * from ${quoteIdent(table)}`);
      for (const row of rows.rows) {
        const keys = Object.keys(row);
        const values = keys.map((key) => row[key]);
        const placeholders = keys.map((_, index) => `$${index + 1}`).join(', ');
        await neon.query(`insert into ${quoteIdent(table)} (${keys.map(quoteIdent).join(', ')}) values (${placeholders})`, values);
      }
      console.log(`✓ ${table}: ${rows.rowCount} rows`);
    }

    // Add source foreign keys after rows are present.
    const foreignKeys = await local.query(`select conname, pg_get_constraintdef(c.oid) definition,
      rel.relname table_name from pg_constraint c join pg_class rel on rel.oid=c.conrelid
      join pg_namespace n on n.oid=rel.relnamespace where n.nspname='public' and c.contype='f'`);
    for (const fk of foreignKeys.rows) {
      await neon.query(`alter table ${quoteIdent(fk.table_name)} add constraint ${quoteIdent(fk.conname)} ${fk.definition}`);
    }
    await neon.query('commit');
    console.log('=== Migration completed successfully ===');
  } catch (error) {
    await neon.query('rollback');
    throw error;
  }
}

main().catch((error) => {
  console.error('Migration failed:', error.message || error.code || String(error));
  process.exitCode = 1;
}).finally(async () => {
  await Promise.allSettled([local.end(), neon.end()]);
});
