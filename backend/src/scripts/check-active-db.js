require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');

sequelize.authenticate()
  .then(() => sequelize.query('select current_database() as database, current_schema() as schema'))
  .then(([rows]) => console.log(JSON.stringify(rows[0])))
  .catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  })
  .finally(() => sequelize.close());
