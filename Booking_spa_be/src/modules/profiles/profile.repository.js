const { getDb } = require('../../config/database');
const profileModel = require('./profile.model');

async function findByUserId(userId) {
  return getDb()(profileModel.tableName).where({ user_id: userId }).first();
}

async function updateByUserId(userId, payload) {
  const [profile] = await getDb()(profileModel.tableName)
    .where({ user_id: userId })
    .update({
      avatar_url: payload.avatarUrl,
      birth_date: payload.birthDate,
      gender: payload.gender,
      address: payload.address,
      updated_at: getDb().fn.now(),
    })
    .returning('*');

  return profile;
}

module.exports = {
  findByUserId,
  updateByUserId,
};
