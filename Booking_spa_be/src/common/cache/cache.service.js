const { getRedis } = require('../../config/redis');
const config = require('../../config/env');
const logger = require('../logger/logger');

async function getJson(key) {
  try {
    const redis = getRedis();
    const raw = await redis.get(key);
    return raw ? JSON.parse(raw) : null;
  } catch (error) {
    logger.warn('Cache read failed', { key, message: error.message });
    return null;
  }
}

async function setJson(key, value, ttlSeconds = config.redis.defaultTtlSeconds) {
  try {
    const redis = getRedis();
    await redis.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  } catch (error) {
    logger.warn('Cache write failed', { key, message: error.message });
  }
}

async function deleteKey(key) {
  try {
    const redis = getRedis();
    await redis.del(key);
  } catch (error) {
    logger.warn('Cache delete failed', { key, message: error.message });
  }
}

module.exports = {
  deleteKey,
  getJson,
  setJson,
};
