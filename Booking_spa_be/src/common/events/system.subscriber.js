const eventBus = require('./event-bus');
const logger = require('../logger/logger');

let registered = false;

function registerSystemSubscribers() {
  if (registered) {
    return;
  }

  eventBus.subscribe('SYSTEM_ERROR', (payload) => {
    logger.error('SYSTEM_ERROR event received', payload);
  });

  eventBus.subscribe('DLQ_ITEM_CREATED', (payload) => {
    logger.warn('DLQ item created', payload);
  });

  registered = true;
}

module.exports = {
  registerSystemSubscribers,
};
