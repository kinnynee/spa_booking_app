const pino = require('pino');
const env = require('../config/env');

const logger = pino({
  level: env.LOG_LEVEL,
  base: {
    app: env.APP_NAME,
    environment: env.NODE_ENV,
  },
  redact: {
    paths: ['req.headers.authorization', 'password', '*.password', '*.token'],
    censor: '[REDACTED]',
  },
  transport:
    env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
            translateTime: 'SYS:standard',
            ignore: 'pid,hostname',
          },
        }
      : undefined,
});

module.exports = logger;
