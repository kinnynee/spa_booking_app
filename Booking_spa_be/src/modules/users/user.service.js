const { AppError } = require('../../common/errors/app-error');
const userRepository = require('./user.repository');
const { toUserDto } = require('./user.dto');

async function listUsers(query) {
  const users = await userRepository.list({
    limit: Number(query.limit) || 50,
    offset: Number(query.offset) || 0,
  });

  return users.map(toUserDto);
}

async function getUser(id) {
  const user = await userRepository.findById(id);

  if (!user) {
    throw new AppError('User not found.', 404, 'USER_NOT_FOUND');
  }

  return toUserDto(user);
}

module.exports = {
  getUser,
  listUsers,
};
