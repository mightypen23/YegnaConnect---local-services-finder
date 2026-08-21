const bcrypt = require('bcryptjs');
const { User } = require('../models');
const { signToken } = require('../utils/jwt');
const { generateCode, expiresAt, normalizePhone, PHONE_REGEX } = require('../utils/otp');
const { sendOtp } = require('./smsProvider');

const BCRYPT_ROUNDS = 10;
const MAX_VERIFY_ATTEMPTS = 5;

class AuthError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

async function requestOtp(phone_number, full_name) {
  const phone = normalizePhone(phone_number);
  if (!PHONE_REGEX.test(phone)) {
    throw new AuthError(400, 'Invalid phone number. Use country code format, e.g. +251911111111');
  }

  const user = await User.findOne({ where: { phone_number: phone } });
  if (!user && !full_name) {
    throw new AuthError(400, 'full_name is required for a new account');
  }

  const code = generateCode();
  try {
    await sendOtp(phone, code);
  } catch {
    throw new AuthError(502, 'Could not send the verification code. Please try again.');
  }

  if (!user) {
    return User.create({
      full_name,
      phone_number: phone,
      verification_code: code,
      verification_code_expires: expiresAt(),
      verification_attempts: 0
    });
  }

  user.verification_code = code;
  user.verification_code_expires = expiresAt();
  user.verification_attempts = 0;
  await user.save();
  return user;
}

async function verifyOtp(phone_number, code) {
  const phone = normalizePhone(phone_number);
  if (!PHONE_REGEX.test(phone)) {
    throw new AuthError(400, 'Invalid phone number. Use country code format, e.g. +251911111111');
  }
  const user = await User.findOne({ where: { phone_number: phone } });

  if (!user) {
    throw new AuthError(404, 'Account not found for this phone number');
  }
  if (!user.verification_code || !user.verification_code_expires) {
    throw new AuthError(400, 'No verification code requested. Request one first.');
  }
  if (user.verification_code_expires < new Date()) {
    throw new AuthError(400, 'Verification code expired. Request a new one.');
  }
  if (user.verification_attempts >= MAX_VERIFY_ATTEMPTS) {
    throw new AuthError(429, 'Too many failed attempts. Request a new code.');
  }

  const codeMatches = compareCodes(code, user.verification_code);
  if (!codeMatches) {
    user.verification_attempts += 1;
    await user.save();
    throw new AuthError(400, `Invalid verification code. ${MAX_VERIFY_ATTEMPTS - user.verification_attempts} attempts left.`);
  }

  user.is_verified = true;
  user.verification_code = null;
  user.verification_code_expires = null;
  user.verification_attempts = 0;
  await user.save();

  return user;
}

function compareCodes(provided, stored) {
  try {
    const a = Buffer.from(provided);
    const b = Buffer.from(stored);
    return a.length === b.length && Buffer.compare(a, b) === 0;
  } catch {
    return false;
  }
}

async function register(full_name, email, password) {
  const existing = await User.findOne({ where: { email } });
  if (existing) {
    throw new AuthError(409, 'An account with this email already exists');
  }

  const password_hash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  const user = await User.create({
    full_name,
    email,
    password_hash,
    is_verified: true
  });
  return user;
}

async function login(email, password) {
  const user = await User.findOne({ where: { email } });
  if (!user || !user.password_hash) {
    throw new AuthError(401, 'Invalid email or password');
  }
  const passwordMatches = await bcrypt.compare(password, user.password_hash);
  if (!passwordMatches) {
    throw new AuthError(401, 'Invalid email or password');
  }
  return user;
}

function issueToken(user) {
  return signToken(user);
}

async function updateProfile(userId, updates) {
  const user = await User.findByPk(userId);
  if (!user) {
    throw new AuthError(404, 'User not found');
  }
  const allowed = ['full_name', 'phone_number', 'location'];
  for (const key of allowed) {
    if (updates[key] !== undefined) {
      user[key] = updates[key];
    }
  }
  await user.save();
  return user;
}

module.exports = { requestOtp, verifyOtp, register, login, issueToken, updateProfile, AuthError };