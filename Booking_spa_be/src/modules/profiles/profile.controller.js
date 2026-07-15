const profileService = require('./profile.service');
const { sendSuccess } = require('../../common/utils/api-response');

async function getMyProfile(req, res) {
  const profile = await profileService.getByUserId(req.user.id);
  return sendSuccess(res, profile);
}

async function updateMyProfile(req, res) {
  const profile = await profileService.updateByUserId(req.user.id, req.validated.body);
  return sendSuccess(res, profile, 'Profile updated.');
}

module.exports = {
  getMyProfile,
  updateMyProfile,
};
