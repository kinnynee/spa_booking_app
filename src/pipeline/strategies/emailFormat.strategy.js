class EmailFormatStrategy {
  constructor(field = 'email') {
    this.name = 'EmailFormatStrategy';
    this.field = field;
    this.pattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  }

  validate(record) {
    if (!this.pattern.test(String(record[this.field] || '').trim())) {
      return {
        valid: false,
        message: `${this.field} must be a valid email address`,
      };
    }

    return { valid: true };
  }
}

module.exports = EmailFormatStrategy;
