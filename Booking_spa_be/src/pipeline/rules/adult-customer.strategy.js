class AdultCustomerStrategy {
  constructor(field = 'birthDate') {
    this.name = 'AdultCustomerStrategy';
    this.field = field;
  }

  validate(record) {
    if (!record[this.field]) {
      return { valid: true };
    }

    const birthDate = new Date(record[this.field]);
    const ageDiff = Date.now() - birthDate.getTime();
    const ageDate = new Date(ageDiff);
    const age = Math.abs(ageDate.getUTCFullYear() - 1970);

    return age >= 18
      ? { valid: true }
      : {
          valid: false,
          message: 'Customer must be at least 18 years old.',
        };
  }
}

module.exports = {
  AdultCustomerStrategy,
};
