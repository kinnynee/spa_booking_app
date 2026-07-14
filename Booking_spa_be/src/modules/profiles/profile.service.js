const { getDb } = require('../../config/database');
const { AppError } = require('../../common/errors/app-error');
const { toUserDto } = require('../users/user.dto');
const profileRepository = require('./profile.repository');

async function getByUserId(userId) {
  const db = getDb();
  const [user, profile] = await Promise.all([
    db('users').where({ id: userId }).first(),
    profileRepository.findByUserId(userId),
  ]);

  if (!user) {
    throw new AppError('Profile not found.', 404, 'PROFILE_NOT_FOUND');
  }

  return toUserDto({ ...user, profile });
}

async function updateByUserId(userId, payload) {
  const db = getDb();

  return db.transaction(async (trx) => {
    const user = await trx('users').where({ id: userId }).first();
    if (!user) {
      throw new AppError('Profile not found.', 404, 'PROFILE_NOT_FOUND');
    }

    const userChanges = {};
    if (payload.fullName !== undefined) {
      userChanges.full_name = payload.fullName;
    }
    if (payload.phone !== undefined) {
      userChanges.phone = payload.phone;
    }

    let updatedUser = user;
    if (Object.keys(userChanges).length > 0) {
      [updatedUser] = await trx('users')
        .where({ id: userId })
        .update({ ...userChanges, updated_at: trx.fn.now() })
        .returning('*');
    }

    const profile = await profileRepository.upsertByUserId(userId, payload, trx);
    return toUserDto({ ...updatedUser, profile });
  });
}

module.exports = {
  getByUserId,
  updateByUserId,
};
