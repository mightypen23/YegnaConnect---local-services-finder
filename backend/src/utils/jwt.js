const jwt = require('jsonwebtoken');

const TOKEN_EXPIRY = '7d'; // 7 days

function signToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role,
      token_version: user.token_version || 0
    },
    process.env.JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  );
}

function verifyToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

module.exports = { signToken, verifyToken };