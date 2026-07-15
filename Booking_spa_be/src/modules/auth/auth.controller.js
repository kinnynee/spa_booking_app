const authService = require('./auth.service');
const { sendCreated, sendSuccess } = require('../../common/utils/api-response');
const { toUserDto } = require('../users/user.dto');

async function register(req, res) {
  const result = await authService.register(req.validated.body);
  return sendCreated(res, result, 'Registration successful.');
}

async function googleLogin(req, res) {
  const result = await authService.loginWithGoogle(req.validated.body.idToken);
  return sendSuccess(res, result, 'Google login successful.');
}

async function login(req, res) {
  const result = await authService.login(req.validated.body);
  return sendSuccess(res, result, 'Login successful.');
}

async function me(req, res) {
  return sendSuccess(res, toUserDto(req.user));
}

module.exports = {
  login,
  googleLogin,
  me,
  register,
};
