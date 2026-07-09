const { Roles } = require('../../common/constants/roles');
const { AppError } = require('../../common/errors/app-error');
const { hashPassword, verifyPassword } = require('../../common/utils/password');
const { signAccessToken, signRefreshToken } = require('../../common/utils/token');
const userRepository = require('../users/user.repository');
const profileRepository = require('../profiles/profile.repository');
const { toUserDto } = require('../users/user.dto');

const ADMIN_LOGIN_ALIAS = 'admin@local.spa';
const ADMIN_EMAIL = 'admin@spa.local';

async function register(payload) {
  const existingUser = await userRepository.findByEmail(payload.email);

  if (existingUser) {
    throw new AppError('Email is already registered.', 409, 'EMAIL_EXISTS');
  }

  const passwordHash = await hashPassword(payload.password);

  const user = await userRepository.createWithProfile({
    fullName: payload.fullName,
    email: payload.email,
    phone: payload.phone,
    passwordHash,
    role: Roles.CUSTOMER,
  });

  const tokens = createTokenPair(user);

  return {
    user: toUserDto(user),
    ...tokens,
  };
}

async function login(payload) {
  const user = await userRepository.findByEmail(normalizeLoginIdentifier(payload.email));

  if (!user || !user.is_active) {
    throw new AppError('Invalid account or password.', 401, 'INVALID_CREDENTIALS');
  }

  const passwordMatches = await verifyPassword(payload.password, user.password_hash);

  if (!passwordMatches) {
    throw new AppError('Invalid account or password.', 401, 'INVALID_CREDENTIALS');
  }

  const profile = await profileRepository.findByUserId(user.id);
  const tokens = createTokenPair(user);

  return {
    user: toUserDto({ ...user, profile }),
    ...tokens,
  };
}

function normalizeLoginIdentifier(value) {
  const account = String(value || '')
    .trim()
    .toLowerCase();
  return account === ADMIN_LOGIN_ALIAS ? ADMIN_EMAIL : account;
}

function createTokenPair(user) {
  const payload = {
    sub: user.id,
    role: user.role,
  };

  return {
    accessToken: signAccessToken(payload),
    refreshToken: signRefreshToken(payload),
    tokenType: 'Bearer',
  };
}

module.exports = {
  login,
  register,
};
