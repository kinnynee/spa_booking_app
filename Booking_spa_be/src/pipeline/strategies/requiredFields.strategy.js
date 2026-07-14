class RequiredFieldsStrategy {
  constructor(fields) {
    this.name = 'RequiredFieldsStrategy';
    this.fields = fields;
  }

  validate(record) {
    const missingFields = this.fields.filter((field) => {
      const value = record[field];
      return value === undefined || value === null || value === '';
    });

    if (missingFields.length > 0) {
      return {
        valid: false,
        message: `Missing required fields: ${missingFields.join(', ')}`,
      };
    }

    return { valid: true };
  }
}

module.exports = RequiredFieldsStrategy;
