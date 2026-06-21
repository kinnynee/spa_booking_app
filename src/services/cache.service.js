const env = require('../config/env');
const { getRedisClient } = require('../config/redis');

async function getJson(key) {
  const redis = await getRedisClient();
  if (!redis) return null;

  const value = await redis.get(key);
  return value ? JSON.parse(value) : null;
}

async function setJson(key, value, ttlSeconds = env.CACHE_TTL_SECONDS) {
  const redis = await getRedisClient();
  if (!redis) return false;

  await redis.set(key, JSON.stringify(value), { EX: ttlSeconds });
  return true;
}

async function deleteKey(key) {
  const redis = await getRedisClient();
  if (!redis) return false;

  await redis.del(key);
  return true;
}

module.exports = {
  deleteKey,
  getJson,
  setJson,
};
