const { getDb } = require('../../config/database');
const profileModel = require('./profile.model');

function findByUserId(userId, db = getDb()) {
  return db(profileModel.tableName).where({ user_id: userId }).first();
}

async function upsertByUserId(userId, payload, db = getDb()) {
  const changes = toProfileChanges(payload);
  const existing = await findByUserId(userId, db);

  if (!existing) {
    const [profile] = await db(profileModel.tableName)
      .insert({ user_id: userId, ...changes })
      .returning('*');
    return profile;
  }

  if (Object.keys(changes).length === 0) {
    return existing;
  }

  const [profile] = await db(profileModel.tableName)
    .where({ user_id: userId })
    .update({ ...changes, updated_at: db.fn.now() })
    .returning('*');
  return profile;
}

function toProfileChanges(payload) {
  const fields = {
    avatarUrl: 'avatar_url',
    birthDate: 'birth_date',
    gender: 'gender',
    address: 'address',
  };
  const changes = {};
  for (const [inputKey, column] of Object.entries(fields)) {
    if (payload[inputKey] !== undefined) {
      changes[column] = payload[inputKey];
    }
  }
  return changes;
}

module.exports = {
  findByUserId,
  upsertByUserId,
};
