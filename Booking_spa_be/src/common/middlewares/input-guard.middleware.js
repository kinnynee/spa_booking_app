const { AppError } = require('../errors/app-error');

const blockedKeys = new Set(['__proto__', 'prototype', 'constructor']);

function hasBlockedKey(value) {
  if (!value || typeof value !== 'object') {
    return false;
  }

  if (Array.isArray(value)) {
    return value.some(hasBlockedKey);
  }

  return Object.keys(value).some((key) => blockedKeys.has(key) || hasBlockedKey(value[key]));
}

function inputGuard(req, _res, next) {
  if (hasBlockedKey(req.body) || hasBlockedKey(req.query) || hasBlockedKey(req.params)) {
    return next(new AppError('Invalid request payload.', 400, 'INVALID_INPUT'));
  }

  return next();
}

module.exports = {
  inputGuard,
};
