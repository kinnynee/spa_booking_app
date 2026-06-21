const js = require('@eslint/js');
const globals = require('globals');

module.exports = [
  {
    ignores: [
      'node_modules/**',
      'coverage/**',
      'logs/**',
      'tmp/**',
      'src/controllers/**',
      'src/dto/**',
      'src/events/**',
      'src/middlewares/**',
      'src/models/**',
      'src/repositories/**',
      'src/services/**',
      'src/utils/**',
      'src/validators/**',
      'src/routes/*.routes.js',
      'src/pipeline/strategies/**',
      'src/pipeline/customer.pipeline.js',
      'src/pipeline/ruleEngine.js',
    ],
  },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: {
        ...globals.node,
        ...globals.jest,
      },
    },
    rules: {
      'no-console': 'warn',
      'no-unused-vars': ['error', { argsIgnorePattern: '^_', caughtErrorsIgnorePattern: '^_' }],
    },
  },
];
