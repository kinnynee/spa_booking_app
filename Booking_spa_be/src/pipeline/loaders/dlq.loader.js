const eventBus = require('../../common/events/event-bus');
const dlqRepository = require('../../modules/dlq/dlq.repository');

async function loadToDlq({ source, record, errors }) {
  const entry = await dlqRepository.create({
    source,
    reason: errors.map((error) => `${error.rule}: ${error.message}`).join('; '),
    payload: record,
  });

  eventBus.publish('DLQ_ITEM_CREATED', {
    id: entry.id,
    source,
  });

  return entry;
}

module.exports = {
  loadToDlq,
};
