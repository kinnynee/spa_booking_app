require('dotenv').config();

const config = require('./src/config/env');

const baseConfig = {
  client: 'pg',
  connection: config.database.url,
  pool: {
    min: config.database.poolMin,
    max: config.database.poolMax,
  },
  migrations: {
    directory: './src/database/migrations',
    tableName: 'knex_migrations',
  },
  seeds: {
    directory: './src/database/seeds',
  },
};

module.exports = {
  development: baseConfig,
  test: {
    ...baseConfig,
    connection: process.env.TEST_DATABASE_URL || config.database.url,
  },
  production: {
    ...baseConfig,
    pool: {
      min: Math.max(config.database.poolMin, 2),
      max: config.database.poolMax,
    },
  },
};
