class EmailFormatStrategy {
  constructor(field = 'email') {
    this.name = 'EmailFormatStrategy';
    this.field = field;
  }

  validate(record) {
    const value = record[this.field];
    const valid = typeof value === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);

    return valid
      ? { valid: true }
      : {
          valid: false,
          message: `${this.field} must be a valid email address.`,
        };
  }
}

module.exports = {
  EmailFormatStrategy,
};
