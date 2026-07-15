class RuleEngine {
  constructor(strategies = []) {
    this.strategies = strategies;
  }

  run(record) {
    const errors = [];

    for (const strategy of this.strategies) {
      const result = strategy.validate(record);

      if (!result.valid) {
        errors.push({
          rule: strategy.name,
          message: result.message,
        });
      }
    }

    return {
      valid: errors.length === 0,
      errors,
      record,
    };
  }
}

module.exports = {
  RuleEngine,
};
