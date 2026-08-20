const { validationResult } = require('express-validator');

/**
 * Middleware that checks express-validator results.
 * If there are validation errors, responds with 422 and the error details.
 * Otherwise, passes control to the next handler.
 *
 * Usage in routes:
 *   router.post('/', [body('field').notEmpty()], validate, controller.method);
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    return res.status(422).json({
      error: 'Validation failed',
      details: errors.array().map((err) => ({
        field: err.path,
        message: err.msg,
        value: err.value
      }))
    });
  }

  next();
};

module.exports = validate;
