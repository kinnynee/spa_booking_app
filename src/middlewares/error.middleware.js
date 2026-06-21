const createError = require('http-errors');
const eventBus = require('../events/eventBus');
const eventTypes = require('../events/eventTypes');
const env = require('../config/env');
const logger = require('../utils/logger');

function notFoundHandler(req, _res, next) {
  next(createError(404, `Route ${req.method} ${req.originalUrl} not found`));
}

function errorHandler(error, req, res, _next) {
  const statusCode = error.status || error.statusCode || 500;
  const response = {
    success: false,
    message: statusCode >= 500 && env.NODE_ENV === 'production' ? 'Internal server error' : error.message,
  };

  if (error.details) response.details = error.details;
  if (env.NODE_ENV !== 'production' && error.stack) response.stack = error.stack;

  logger.error(
    {
      error: error.message,
      stack: error.stack,
      statusCode,
      path: req.originalUrl,
      method: req.method,
    },
    'Request failed'
  );

  if (statusCode >= 500) {
    eventBus.emit(eventTypes.SYSTEM_ERROR, {
      message: error.message,
      stack: error.stack,
      path: req.originalUrl,
      method: req.method,
    });
  }

  res.status(statusCode).json(response);
}

module.exports = {
  errorHandler,
  notFoundHandler,
};
