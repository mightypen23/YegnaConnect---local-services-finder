const crypto = require('crypto');

const OTP_TTL_MS = 5 * 60 * 1000;
const PHONE_REGEX = /^\+?[1-9]\d{7,14}$/;

function generateCode() {
  return crypto.randomInt(0, 1000000).toString().padStart(6, '0');
}

function expiresAt() {
  return new Date(Date.now() + OTP_TTL_MS); 
}

function normalizePhone(input) {
  let p = String(input || '').trim();
  p = p.replace(/[\s\-()]/g, '');
  if (p.startsWith('+')) {
    return p;
  }
  if (p.startsWith('00')) {
    return '+' + p.slice(2);
  }
  if (p.startsWith('0')) {
    return '+251' + p.slice(1);
  }
  if (/^\d{9}$/.test(p)) {
    return '+251' + p;
  }
  if (/^\d{12}$/.test(p)) {
    return '+' + p;
  }
  return p;
}

module.exports = { generateCode, expiresAt, normalizePhone, OTP_TTL_MS, PHONE_REGEX };