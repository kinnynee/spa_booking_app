const fs = require('fs/promises');
const path = require('path');
const eventBus = require('../eventBus');
const eventTypes = require('../eventTypes');
const env = require('../../config/env');
const logger = require('../../utils/logger');

async function appendLogFile(fileName, payload) {
  const logDir = path.resolve(process.cwd(), 'logs');
  await fs.mkdir(logDir, { recursive: true });
  await fs.appendFile(
    path.join(logDir, fileName),
    `${JSON.stringify({ timestamp: new Date().toISOString(), ...payload })}\n`
  );
}

async function notifyDiscord(payload) {
  if (!env.DISCORD_WEBHOOK_URL || typeof fetch !== 'function') return;

  try {
    await fetch(env.DISCORD_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        content: `Spa Booking API alert: ${payload.message || 'system event'}`,
      }),
    });
  } catch (error) {
    logger.warn({ error: error.message }, 'Discord webhook notification failed');
  }
}

function registerSystemLogSubscriber() {
  eventBus.on(eventTypes.SYSTEM_ERROR, async (payload) => {
    await appendLogFile('errors.log', payload);
    await notifyDiscord(payload);
  });

  eventBus.on(eventTypes.DLQ_CREATED, async (payload) => {
    await appendLogFile('dlq.log', payload);
  });
}

module.exports = registerSystemLogSubscriber;
