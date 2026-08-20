const { verifyToken } = require('../utils/jwt');
const { User } = require('../models');

function authenticate(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) return res.status(401).json({ error: 'No token provided' });

  let payload;
  try {
    payload = verifyToken(token);
  } catch {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }

  User.findByPk(payload.sub)
    .then((user) => {
      if (!user) return res.status(401).json({ error: 'User no longer exists' });
      if (user.token_version !== payload.token_version) {
        return res.status(401).json({ error: 'Token revoked. Please sign in again.' });
      }
      req.user = user;
      return next();
    })
    .catch(next);
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) return res.status(401).json({ error: 'Authentication required' });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    return next();
  };
}

const requireAdmin = requireRole('admin');

module.exports = { authenticate, requireRole, requireAdmin };
