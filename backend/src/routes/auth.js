const express = require('express');
const rateLimit = require('express-rate-limit');
const router = express.Router();

const {
  requestOtpValidators,
  verifyOtpValidators,
  registerValidators,
  loginValidators,
  updateProfileValidators,
  requestOtp,
  verifyOtp,
  register,
  login,
  me,
  updateMe,
  deleteMe
} = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');

const otpRequestLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many OTP requests. Try again later.' }
});

const otpVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Too many verification attempts. Try again later.' }
});

router.post('/otp/request', otpRequestLimiter, requestOtpValidators, requestOtp);
router.post('/otp/verify', otpVerifyLimiter, verifyOtpValidators, verifyOtp);
router.post('/register', registerValidators, register);
router.post('/login', loginValidators, login);
router.get('/me', authenticate, me);
router.put('/me', authenticate, updateProfileValidators, updateMe);
router.delete('/me', authenticate, deleteMe);

module.exports = router;