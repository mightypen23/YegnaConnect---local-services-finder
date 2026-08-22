/**
 * Wraps an async route handler so that any rejected promise
 * is automatically forwarded to the Express error-handling middleware.
 *
 * Usage:  router.get('/path', asyncHandler(controller.method));
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch((err) => {
    const status = err.status || err.statusCode;
    if (status && status >= 400 && status < 500) {
      return res.status(status).json({ error: err.message });
    }
    if (err.name === 'UniqueConstraintError') {
      return res.status(409).json({ error: err.errors?.[0]?.message || 'Resource already exists' });
    }
    if (err.name === 'ForeignKeyConstraintError') {
      return res.status(400).json({ error: 'Referenced resource does not exist' });
    }
    return next(err);
  });
};

module.exports = asyncHandler;
