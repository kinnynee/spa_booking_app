const userService = require('./user.service');
const { sendSuccess } = require('../../common/utils/api-response');

async function listUsers(req, res) {
  const users = await userService.listUsers(req.query);
  return sendSuccess(res, users);
}

async function getUser(req, res) {
  const user = await userService.getUser(req.params.id);
  return sendSuccess(res, user);
}

module.exports = {
  getUser,
  listUsers,
};
