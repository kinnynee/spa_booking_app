const knex = require('knex');

const config = require('./env');
const knexConfig = require('../../knexfile');

let db;

function getDb() {
  if (!db) {
    db = knex(knexConfig[config.env] || knexConfig.development);
  }

  return db;
}

async function closeDb() {
  if (db) {
    await db.destroy();
    db = undefined;
  }
}

module.exports = {
  getDb,
  closeDb,
};
