/**
 * Authentication middleware (development stub).
 *
 * In production, replace the header-based lookup with JWT verification
 * or session-based authentication. The contract is:
 *   req.user = { id: <UUID>, role: 'customer' | 'provider' | 'admin' }
 */

/**
 * Require a valid authenticated user on req.user.
 * Dev mode: reads x-user-id and x-user-role headers.
 */
const authenticate = (req, res, next) => {
  const userId = req.headers['x-user-id'];
  const userRole = req.headers['x-user-role'];

  if (!userId) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  req.user = {
    id: userId,
    role: userRole || 'customer'
  };

  next();
};

/**
 * Require the authenticated user to have one of the specified roles.
 * Must be used after `authenticate`.
 *
 * @param  {...string} roles  Allowed roles, e.g. 'admin', 'provider'
 */
const requireRole = (...roles) => (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  if (!roles.includes(req.user.role)) {
    return res.status(403).json({
      error: 'Insufficient permissions',
      required: roles,
      current: req.user.role
    });
  }

  next();
};

module.exports = { authenticate, requireRole };
