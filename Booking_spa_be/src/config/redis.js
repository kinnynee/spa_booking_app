const Redis = require('ioredis');

const config = require('./env');
const logger = require('../common/logger/logger');

let redis;

function getRedis() {
  if (!redis) {
    redis = new Redis(config.redis.url, {
      lazyConnect: true,
      maxRetriesPerRequest: 1,
    });

    redis.on('error', (error) => {
      logger.warn('Redis error', { message: error.message });
    });
  }

  return redis;
}

async function connectRedis() {
  const client = getRedis();

  if (client.status === 'wait') {
    await client.connect();
  }

  return client;
}

async function closeRedis() {
  if (redis) {
    await redis.quit();
    redis = undefined;
  }
}

module.exports = {
  getRedis,
  connectRedis,
  closeRedis,
};
