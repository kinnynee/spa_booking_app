const eventBus = require('../events/event-bus');
const logger = require('../logger/logger');
const config = require('../../config/env');

function errorHandler(error, req, res, _next) {
  const statusCode = error.statusCode || error.status || 500;
  const isServerError = statusCode >= 500;
  const response = {
    success: false,
    message: isServerError ? 'Internal server error.' : error.message || 'Request failed.',
    code: error.code || 'INTERNAL_ERROR',
    requestId: req.id,
  };

  if (error.details) {
    response.details = error.details;
  }

  if (config.env !== 'production' && error.stack && !isServerError) {
    response.stack = error.stack;
  }

  logger.error('Request failed', {
    requestId: req.id,
    method: req.method,
    url: req.originalUrl,
    statusCode,
    message: error.message,
    stack: error.stack,
  });

  if (statusCode >= 500) {
    eventBus.publish('SYSTEM_ERROR', {
      requestId: req.id,
      message: error.message,
      stack: error.stack,
    });
  }

  return res.status(statusCode).json(response);
}

module.exports = {
  errorHandler,
};
