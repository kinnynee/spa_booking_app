const http = require('http');

const app = require('./app');
const config = require('./config/env');
const { closeDb } = require('./config/database');
const { closeRedis } = require('./config/redis');
const logger = require('./common/logger/logger');

const server = http.createServer(app);

server.listen(config.app.port, () => {
  logger.info('API server started', {
    app: config.app.name,
    env: config.env,
    port: config.app.port,
    prefix: config.app.apiPrefix,
  });
});

async function shutdown(signal) {
  logger.info('Shutdown signal received', { signal });

  server.close(async () => {
    await Promise.allSettled([closeDb(), closeRedis()]);
    logger.info('HTTP server closed');
    process.exit(0);
  });
}

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled promise rejection', { reason });
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception', { message: error.message, stack: error.stack });
  process.exit(1);
});
