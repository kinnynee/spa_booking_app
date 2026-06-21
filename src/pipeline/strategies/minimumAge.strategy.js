class MinimumAgeStrategy {
  constructor(field = 'age', minimumAge = 18) {
    this.name = 'MinimumAgeStrategy';
    this.field = field;
    this.minimumAge = minimumAge;
  }

  validate(record) {
    const age = Number(record[this.field]);
    if (!Number.isFinite(age) || age < this.minimumAge) {
      return {
        valid: false,
        message: `${this.field} must be at least ${this.minimumAge}`,
      };
    }

    return { valid: true };
  }
}

module.exports = MinimumAgeStrategy;
