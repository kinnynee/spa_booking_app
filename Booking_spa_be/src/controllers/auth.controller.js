const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const authService = require('../services/auth.service');
const userService = require('../services/user.service');

const register = asyncHandler(async (req, res) => {
  const user = await authService.register(req.body);
  return sendSuccess(res, {
    statusCode: 201,
    message: 'User registered successfully',
    data: user,
  });
});

const me = asyncHandler(async (req, res) => {
  const user = await userService.getOrCreateCurrentUser(req.user);
  return sendSuccess(res, {
    message: 'Current user profile',
    data: user,
  });
});

module.exports = {
  me,
  register,
};
