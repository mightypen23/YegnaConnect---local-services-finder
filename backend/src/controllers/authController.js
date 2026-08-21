const { body, validationResult } = require('express-validator');
const { UniqueConstraintError } = require('sequelize');
const {
  requestOtp: requestOtpService,
  verifyOtp: verifyOtpService,
  register: registerService,
  login: loginService,
  issueToken,
  AuthError
} = require('../services/authService');

function asyncHandler(fn) {
  return (req, res, next) => {
    fn(req, res, next).catch((err) => {
      if (err instanceof AuthError) {
        return res.status(err.status).json({ error: err.message });
      }
      if (err instanceof UniqueConstraintError) {
        return res.status(409).json({ error: 'An account with this phone or email already exists' });
      }
      // Bug #7 fix: properly distinguish validation errors vs uniqueness errors
      if (err.name === 'SequelizeValidationError') {
        return res.status(400).json({ error: err.errors?.[0]?.message || 'Validation failed' });
      }
      if (err.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({ error: 'An account with this phone or email already exists' });
      }
      return next(err);
    });
  };
}

function requireValid(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ error: errors.array()[0].msg });
    return false;
  }
  return true;
}

function sanitizeUser(user) {
  const u = user.toJSON ? user.toJSON() : user;
  return {
    id: u.id,
    full_name: u.full_name,
    phone_number: u.phone_number,
    profile_image: u.profile_image,
    email: u.email,
    role: u.role,
    is_verified: u.is_verified,
    created_at: u.created_at,
    updated_at: u.updated_at
  };
}

const requestOtpValidators = [
  body('phone_number').trim().notEmpty().withMessage('Phone number is required'),
  body('full_name')
    .optional({ checkFalsy: true })
    .trim()
    .notEmpty()
    .withMessage('Full name cannot be empty')
];

const verifyOtpValidators = [
  body('phone_number').trim().notEmpty().withMessage('Phone number is required'),
  body('code').matches(/^\d{6}$/).withMessage('Invalid verification code')
];

const registerValidators = [
  body('full_name').trim().notEmpty().withMessage('Full name is required'),
  body('email').isEmail().withMessage('Invalid email address'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters')
];

const loginValidators = [
  body('email').isEmail().withMessage('Invalid email address'),
  body('password').notEmpty().withMessage('Password is required')
];

// Bug #8 fix: Ethiopian mobile numbers only (+251 followed by 7x or 9x and 8 more digits)
const ETHIOPIAN_PHONE_REGEX = /^\+251[79]\d{8}$/;

const updateMeValidators = [
  body('full_name').optional().trim().notEmpty().withMessage('Full name cannot be empty'),
  body('phone_number')
    .optional({ nullable: true })
    .custom((value) => {
      if (value === null || value === '') return true;
      if (!ETHIOPIAN_PHONE_REGEX.test(value)) {
        throw new Error('Invalid Ethiopian phone number. Use format: +251911234567');
      }
      return true;
    }),
  body('profile_image')
    .optional({ nullable: true })
    .isString()
    .isLength({ max: 5 * 1024 * 1024 })
    .withMessage('Profile image is too large')
];

const requestOtp = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { phone_number, full_name } = req.body;
  const user = await requestOtpService(phone_number, full_name);
  const devCode = process.env.NODE_ENV === 'development' ? user.verification_code : undefined;
  res.json({
    success: true,
    message: 'Verification code sent',
    ...(devCode ? { dev_code: devCode } : {})
  });
});

const verifyOtp = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { phone_number, code } = req.body;
  const user = await verifyOtpService(phone_number, code);
  res.json({ token: issueToken(user), user: sanitizeUser(user) });
});

const register = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { full_name, email, password } = req.body;
  const user = await registerService(full_name, email, password);
  res.status(201).json({ token: issueToken(user), user: sanitizeUser(user) });
});

const login = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { email, password } = req.body;
  const user = await loginService(email, password);
  res.json({ token: issueToken(user), user: sanitizeUser(user) });
});

const me = asyncHandler(async (req, res) => {
  res.json({ user: sanitizeUser(req.user) });
});

const updateMe = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  if (req.body.full_name !== undefined) req.user.full_name = req.body.full_name;
  if (req.body.phone_number !== undefined) req.user.phone_number = req.body.phone_number || null;
  if (req.body.profile_image !== undefined) req.user.profile_image = req.body.profile_image || null;
  await req.user.save();
  res.json({ user: sanitizeUser(req.user) });
});

module.exports = {
  requestOtpValidators,
  verifyOtpValidators,
  registerValidators,
  loginValidators,
  requestOtp,
  verifyOtp,
  register,
  login,
  me,
  updateMeValidators,
  updateMe
};
