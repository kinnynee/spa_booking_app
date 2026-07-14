const { getDb } = require('../../config/database');

function find() {
  return getDb()('spa_settings').where({ id: 1 }).first();
}

async function update(payload) {
  const [settings] = await getDb()('spa_settings')
    .where({ id: 1 })
    .update({ ...payload, updated_at: getDb().fn.now() })
    .returning('*');
  return settings ?? null;
}

module.exports = {
  find,
  update,
};
