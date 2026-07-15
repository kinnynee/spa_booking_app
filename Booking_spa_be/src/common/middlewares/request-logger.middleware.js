const morgan = require('morgan');

const logger = require('../logger/logger');

const requestLogger = morgan(':method :url :status :response-time ms - :res[content-length]', {
  stream: {
    write: (message) => logger.http(message.trim()),
  },
});

module.exports = {
  requestLogger,
};
