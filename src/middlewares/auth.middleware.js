const createError = require('http-errors');
const { getAuth } = require('../config/firebase');
const userRepository = require('../repositories/user.repository');

function getBearerToken(req) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) return null;
  return token;
}

async function attachUser(req, decodedToken) {
  const profile = await userRepository.findById(decodedToken.uid);
  req.user = {
    uid: decodedToken.uid,
    email: decodedToken.email || profile?.email || '',
    role: decodedToken.role || profile?.role || 'customer',
    profile,
  };
}

async function authenticate(req, _res, next) {
  try {
    const token = getBearerToken(req);
    if (!token) throw createError(401, 'Missing bearer token');

    const decodedToken = await getAuth().verifyIdToken(token);
    await attachUser(req, decodedToken);
    return next();
  } catch (error) {
    return next(createError(401, error.message || 'Unauthorized'));
  }
}

async function optionalAuthenticate(req, _res, next) {
  try {
    const token = getBearerToken(req);
    if (!token) return next();

    const decodedToken = await getAuth().verifyIdToken(token);
    await attachUser(req, decodedToken);
    return next();
  } catch (_error) {
    return next();
  }
}

function authorizeRoles(...roles) {
  return (req, _res, next) => {
    if (!req.user) return next(createError(401, 'Authentication required'));
    if (!roles.includes(req.user.role)) return next(createError(403, 'Forbidden'));
    return next();
  };
}

module.exports = {
  authenticate,
  authorizeRoles,
  optionalAuthenticate,
};
