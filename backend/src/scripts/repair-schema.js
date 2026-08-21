require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');
require('../models');

async function repairSchema() {
  console.log('=== YegnaConnect Schema Repair ===');
  console.log('This operation preserves rows and updates tables to match the current models.');

  try {
    await sequelize.authenticate();
    console.log('✓ Connected to PostgreSQL');

    await sequelize.sync({ alter: true });
    console.log('✓ All model tables and columns synchronized');

    const tables = await sequelize.getQueryInterface().showAllTables();
    console.log(`✓ Verified ${tables.length} database tables`);
  } catch (error) {
    console.error('Schema repair failed:', error.message);
    if (error.parent) console.error('SQL Error:', error.parent.message);
    process.exitCode = 1;
  } finally {
    await sequelize.close();
  }
}

repairSchema();
