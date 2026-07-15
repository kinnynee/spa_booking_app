const dlqRepository = require('../repositories/dlq.repository');
const pipelineCustomerRepository = require('../repositories/pipelineCustomer.repository');
const eventBus = require('../events/eventBus');
const eventTypes = require('../events/eventTypes');
const { createCustomerPipeline } = require('../pipeline/customer.pipeline');

async function importCustomers(items) {
  const pipeline = createCustomerPipeline();
  const summary = {
    extracted: items.length,
    loaded: 0,
    rejected: 0,
    rejectedItems: [],
  };

  for (const rawRecord of items) {
    const validation = pipeline.validate(rawRecord);

    if (!validation.valid) {
      const dlqRecord = await dlqRepository.create({
        source: 'customer_import',
        payload: rawRecord,
        errors: validation.errors,
        status: 'pending',
      });

      summary.rejected += 1;
      summary.rejectedItems.push({
        id: dlqRecord.id,
        errors: validation.errors,
      });

      eventBus.emit(eventTypes.DLQ_CREATED, {
        id: dlqRecord.id,
        source: 'customer_import',
        errors: validation.errors,
      });

      continue;
    }

    const transformedRecord = pipeline.transform(rawRecord);
    await pipelineCustomerRepository.create(transformedRecord);
    summary.loaded += 1;
  }

  return summary;
}

module.exports = {
  importCustomers,
};
