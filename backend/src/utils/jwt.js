const jwt = require('jsonwebtoken');

function signToken(user) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role,
      token_version: user.token_version
    },
    process.env.JWT_SECRET
  );
}

function verifyToken(token) {
  return jwt.verify(token, process.env.JWT_SECRET);
}

module.exports = { signToken, verifyToken };