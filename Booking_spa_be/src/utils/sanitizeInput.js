const blockedKeys = new Set(['__proto__', 'constructor', 'prototype']);

function sanitizeValue(value) {
  if (Array.isArray(value)) return value.map(sanitizeValue);
  if (!value || typeof value !== 'object') return value;

  return Object.entries(value).reduce((clean, [key, nestedValue]) => {
    if (blockedKeys.has(key) || key.startsWith('$') || key.includes('.')) {
      return clean;
    }

    clean[key] = sanitizeValue(nestedValue);
    return clean;
  }, {});
}

function sanitizeRequest(req, _res, next) {
  req.body = sanitizeValue(req.body);
  req.query = sanitizeValue(req.query);
  req.params = sanitizeValue(req.params);
  next();
}

module.exports = {
  sanitizeRequest,
  sanitizeValue,
};
