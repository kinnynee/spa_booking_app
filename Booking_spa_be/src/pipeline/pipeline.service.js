const { RuleEngine } = require('./rule-engine');
const { AdultCustomerStrategy } = require('./rules/adult-customer.strategy');
const { EmailFormatStrategy } = require('./rules/email-format.strategy');
const { RequiredFieldsStrategy } = require('./rules/required-fields.strategy');
const { transformCustomer } = require('./transformers/customer.transformer');
const { loadToDlq } = require('./loaders/dlq.loader');

const customerRuleEngine = new RuleEngine([
  new RequiredFieldsStrategy(['fullName', 'email']),
  new EmailFormatStrategy('email'),
  new AdultCustomerStrategy('birthDate'),
]);

async function processCustomerRecords(records, source = 'api') {
  const validRecords = [];
  const invalidRecords = [];

  for (const rawRecord of records) {
    const transformed = transformCustomer(rawRecord);
    const result = customerRuleEngine.run(transformed);

    if (result.valid) {
      validRecords.push(transformed);
    } else {
      const dlqEntry = await loadToDlq({
        source,
        record: rawRecord,
        errors: result.errors,
      });

      invalidRecords.push(dlqEntry);
    }
  }

  return {
    validRecords,
    invalidRecords,
  };
}

module.exports = {
  processCustomerRecords,
};
