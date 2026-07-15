const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const userService = require('../services/user.service');

const getMe = asyncHandler(async (req, res) => {
  const user = await userService.getOrCreateCurrentUser(req.user);
  return sendSuccess(res, {
    message: 'Current user profile',
    data: user,
  });
});

const updateMe = asyncHandler(async (req, res) => {
  const user = await userService.updateMe(req.user.uid, req.body);
  return sendSuccess(res, {
    message: 'Profile updated successfully',
    data: user,
  });
});

const uploadAvatar = asyncHandler(async (req, res) => {
  const staticBaseUrl = `${req.protocol}://${req.get('host')}/static`;
  const user = await userService.uploadAvatar(req.user.uid, req.file, staticBaseUrl);

  return sendSuccess(res, {
    message: 'Avatar uploaded successfully',
    data: user,
  });
});

const listUsers = asyncHandler(async (req, res) => {
  const users = await userService.listUsers(req.query);
  return sendSuccess(res, {
    message: 'Users fetched successfully',
    data: users,
  });
});

const setUserRole = asyncHandler(async (req, res) => {
  const user = await userService.setUserRole(req.params.uid, req.body.role);
  return sendSuccess(res, {
    message: 'User role updated successfully',
    data: user,
  });
});

module.exports = {
  getMe,
  listUsers,
  setUserRole,
  updateMe,
  uploadAvatar,
};
