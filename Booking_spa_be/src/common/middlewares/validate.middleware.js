const { AppError } = require('../errors/app-error');

function validate(schema) {
  return (req, _res, next) => {
    const result = schema.safeParse({
      body: req.body,
      params: req.params,
      query: req.query,
    });

    if (!result.success) {
      const details = result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
      }));

      return next(new AppError('Validation failed.', 400, 'VALIDATION_ERROR', details));
    }

    req.validated = result.data;
    return next();
  };
}

module.exports = {
  validate,
};
