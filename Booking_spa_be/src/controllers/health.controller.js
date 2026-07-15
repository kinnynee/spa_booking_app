const { sendSuccess } = require('../utils/apiResponse');
const env = require('../config/env');

function healthCheck(_req, res) {
  return sendSuccess(res, {
    message: 'API is healthy',
    data: {
      app: env.APP_NAME,
      environment: env.NODE_ENV,
      uptimeSeconds: Math.round(process.uptime()),
      timestamp: new Date().toISOString(),
    },
  });
}

module.exports = {
  healthCheck,
};
