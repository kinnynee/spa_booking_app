class RequiredFieldsStrategy {
  constructor(fields) {
    this.name = 'RequiredFieldsStrategy';
    this.fields = fields;
  }

  validate(record) {
    const missing = this.fields.filter((field) => record[field] === undefined || record[field] === null);

    if (missing.length > 0) {
      return {
        valid: false,
        message: `Missing required fields: ${missing.join(', ')}`,
      };
    }

    return { valid: true };
  }
}

module.exports = {
  RequiredFieldsStrategy,
};
