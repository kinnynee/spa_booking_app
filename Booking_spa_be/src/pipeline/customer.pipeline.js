const RuleEngine = require('./ruleEngine');
const RequiredFieldsStrategy = require('./strategies/requiredFields.strategy');
const EmailFormatStrategy = require('./strategies/emailFormat.strategy');
const MinimumAgeStrategy = require('./strategies/minimumAge.strategy');

function normalizeName(name) {
  return String(name || '')
    .trim()
    .replace(/\s+/g, ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase());
}

function transformCustomerRecord(record) {
  return {
    fullName: normalizeName(record.fullName || record.name),
    email: String(record.email).trim().toLowerCase(),
    phoneNumber: String(record.phoneNumber || '').trim(),
    age: Number(record.age),
    importedAt: new Date().toISOString(),
  };
}

function createCustomerPipeline() {
  const ruleEngine = new RuleEngine([
    new RequiredFieldsStrategy(['email', 'age']),
    new EmailFormatStrategy('email'),
    new MinimumAgeStrategy('age', 18),
  ]);

  return {
    validate: (record) => ruleEngine.validate(record),
    transform: transformCustomerRecord,
  };
}

module.exports = {
  createCustomerPipeline,
};
