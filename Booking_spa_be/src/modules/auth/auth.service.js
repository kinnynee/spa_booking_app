const crypto = require('crypto');
const { OAuth2Client } = require('google-auth-library');

const config = require('../../config/env');
const logger = require('../../common/logger/logger');
const { Roles } = require('../../common/constants/roles');
const { AppError } = require('../../common/errors/app-error');
const { hashPassword, verifyPassword } = require('../../common/utils/password');
const { signAccessToken, signRefreshToken } = require('../../common/utils/token');
const userRepository = require('../users/user.repository');
const profileRepository = require('../profiles/profile.repository');
const { toUserDto } = require('../users/user.dto');

const ADMIN_LOGIN_ALIAS = 'admin@local.spa';
const ADMIN_EMAIL = 'admin@spa.local';

let googleOAuthClient;

function getGoogleTokenMetadata(idToken) {
  const payloadSegment = String(idToken || '').split('.')[1];
  if (!payloadSegment) {
    return {};
  }

  try {
    const payload = JSON.parse(Buffer.from(payloadSegment, 'base64url').toString('utf8'));
    return {
      audience: payload.aud || null,
      issuer: payload.iss || null,
      issuedAt: payload.iat || null,
      expiresAt: payload.exp || null,
    };
  } catch (_) {
    return {};
  }
}

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

async function loginWithGoogle(idToken) {
  const googleProfile = await verifyGoogleIdToken(idToken);
  let user = await userRepository.findByGoogleSubject(googleProfile.subject);

  if (!user) {
    user = await userRepository.findByEmail(googleProfile.email);

    if (user?.google_subject && user.google_subject !== googleProfile.subject) {
      throw new AppError(
        'This email is already linked to a different Google account.',
        409,
        'GOOGLE_ACCOUNT_MISMATCH',
      );
    }

    if (user && !user.google_subject) {
      user = await userRepository.setGoogleSubject(user.id, googleProfile.subject);
    }
  }

  if (user && !user.is_active) {
    throw new AppError('User is not allowed to access this resource.', 401, 'AUTH_INVALID');
  }

  if (!user) {
    user = await userRepository.createWithProfile({
      fullName: googleProfile.name,
      email: googleProfile.email,
      phone: null,
      passwordHash: await hashPassword(createUnusablePassword()),
      googleSubject: googleProfile.subject,
      avatarUrl: googleProfile.avatarUrl,
      role: Roles.CUSTOMER,
    });
  }

  const profile = await profileRepository.findByUserId(user.id);
  return {
    user: toUserDto({ ...user, profile }),
    ...createTokenPair(user),
  };
}

async function verifyGoogleIdToken(idToken) {
  const clientId = config.google.oauthClientId;
  if (!clientId) {
    throw new AppError(
      'Google Sign-In is not configured on the server.',
      503,
      'GOOGLE_SIGN_IN_UNAVAILABLE',
    );
  }

  try {
    googleOAuthClient ??= new OAuth2Client(clientId);
    const ticket = await googleOAuthClient.verifyIdToken({
      idToken,
      audience: clientId,
    });
    const payload = ticket.getPayload();
    const email = payload?.email?.trim().toLowerCase();
    const subject = payload?.sub;

    if (!subject || !email || payload.email_verified !== true || email.length > 160) {
      throw new AppError('Google account could not be verified.', 401, 'GOOGLE_TOKEN_INVALID');
    }

    return {
      subject,
      email,
      name: normalizeGoogleName(payload.name, email),
      avatarUrl: payload.picture || null,
    };
  } catch (error) {
    logger.warn('Google ID token verification failed', {
      message: error.message,
      expectedAudience: clientId,
      token: getGoogleTokenMetadata(idToken),
    });
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError('Google token is invalid or expired.', 401, 'GOOGLE_TOKEN_INVALID');
  }
}

function normalizeGoogleName(name, email) {
  const normalizedName = String(name || '').trim().slice(0, 120);
  if (normalizedName) {
    return normalizedName;
  }
  return email.split('@')[0].slice(0, 120) || 'Google user';
}

function createUnusablePassword() {
  return crypto.randomBytes(48).toString('base64url');
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
  loginWithGoogle,
  register,
};
