class RuleEngine {
  constructor(strategies = []) {
    this.strategies = strategies;
  }

  validate(record) {
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
    };
  }
}

module.exports = RuleEngine;
