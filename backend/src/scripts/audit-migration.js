require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { Client } = require('pg');

const localConfig = {
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: String(process.env.DB_PASSWORD || '')
};
const neonUrl = process.env.NEON_DATABASE_URL || process.env.DATABASE_URL;

async function inspect(label, client) {
  await client.connect();
  const identity = await client.query('select current_database() as database, current_schema() as schema');
  const tables = await client.query(`
    select table_name
    from information_schema.tables
    where table_schema = 'public' and table_type = 'BASE TABLE'
    order by table_name
  `);
  const counts = {};
  for (const { table_name: table } of tables.rows) {
    const result = await client.query(`select count(*)::int as count from "${table.replace(/"/g, '""')}"`);
    counts[table] = result.rows[0].count;
  }
  console.log(JSON.stringify({ label, ...identity.rows[0], tables: counts }, null, 2));
  await client.end();
}

async function main() {
  if (!neonUrl) throw new Error('NEON_DATABASE_URL or DATABASE_URL is required');
  await inspect('local', new Client(localConfig));
  // Neon URLs already carry sslmode=require; let node-postgres parse it.
  await inspect('neon', new Client({ connectionString: neonUrl }));
}

main().catch((error) => {
  console.error('Migration audit failed:', error.message || error.code || error.name || String(error));
  if (error.code) console.error(`Code: ${error.code}`);
  if (error.stack) console.error(error.stack);
  process.exitCode = 1;
});
