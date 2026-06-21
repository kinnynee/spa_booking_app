const { getDb } = require('../../config/database');

async function create(entry) {
  const [record] = await getDb()('dlq_entries')
    .insert({
      source: entry.source,
      reason: entry.reason,
      payload: entry.payload,
    })
    .returning('*');

  return record;
}

module.exports = {
  create,
};
