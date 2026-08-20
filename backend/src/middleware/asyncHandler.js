/**
 * Wraps an async route handler so that any rejected promise
 * is automatically forwarded to the Express error-handling middleware.
 *
 * Usage:  router.get('/path', asyncHandler(controller.method));
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
