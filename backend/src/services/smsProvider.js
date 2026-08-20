function sendOtp(phone, code) {
  if (process.env.NODE_ENV === 'development') {
    console.log(`[MOCK SMS] To ${phone}: Your YegnaConnect verification code is ${code}`);
    return Promise.resolve({ delivered: true, mock: true });
  }
  return Promise.reject(new Error('SMS provider not configured. Implement Africa\'s Talking integration here.'));
}

module.exports = { sendOtp };