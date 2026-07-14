const { getDb } = require('../../config/database');
const { getRedis } = require('../../config/redis');
const { sendSuccess } = require('../../common/utils/api-response');

async function liveness(_req, res) {
  return sendSuccess(res, {
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
}

async function readiness(_req, res) {
  const checks = {
    database: false,
    redis: false,
  };

  try {
    await getDb().raw('select 1');
    checks.database = true;
  } catch (_error) {
    checks.database = false;
  }

  try {
    const redis = getRedis();
    checks.redis = (await redis.ping()) === 'PONG';
  } catch (_error) {
    checks.redis = false;
  }

  const ready = Object.values(checks).every(Boolean);

  return res.status(ready ? 200 : 503).json({
    success: ready,
    message: ready ? 'Ready' : 'Not ready',
    data: checks,
  });
}

module.exports = {
  liveness,
  readiness,
};
