const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const hpp = require('hpp');

const config = require('../../config/env');

const helmetMiddleware = helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
});

const corsMiddleware = cors({
  origin: config.cors.origin,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-Id'],
});

const globalRateLimiter = rateLimit({
  windowMs: config.security.rateLimitWindowMs,
  max: config.security.rateLimitMax,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
});

const authRateLimiter = rateLimit({
  windowMs: config.security.rateLimitWindowMs,
  max: config.security.authRateLimitMax,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts. Please try again later.',
    code: 'RATE_LIMITED',
  },
});

module.exports = {
  authRateLimiter,
  corsMiddleware,
  globalRateLimiter,
  helmetMiddleware,
  hppMiddleware: hpp(),
};
