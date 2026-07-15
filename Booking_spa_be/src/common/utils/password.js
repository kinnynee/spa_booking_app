const bcrypt = require('bcryptjs');

const config = require('../../config/env');

async function hashPassword(plainTextPassword) {
  return bcrypt.hash(plainTextPassword, config.password.saltRounds);
}

async function verifyPassword(plainTextPassword, passwordHash) {
  return bcrypt.compare(plainTextPassword, passwordHash);
}

module.exports = {
  hashPassword,
  verifyPassword,
};
