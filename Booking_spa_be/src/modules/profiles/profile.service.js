const { AppError } = require('../../common/errors/app-error');
const profileRepository = require('./profile.repository');

async function getByUserId(userId) {
  const profile = await profileRepository.findByUserId(userId);

  if (!profile) {
    throw new AppError('Profile not found.', 404, 'PROFILE_NOT_FOUND');
  }

  return profile;
}

async function updateByUserId(userId, payload) {
  const profile = await profileRepository.updateByUserId(userId, payload);

  if (!profile) {
    throw new AppError('Profile not found.', 404, 'PROFILE_NOT_FOUND');
  }

  return profile;
}

module.exports = {
  getByUserId,
  updateByUserId,
};
