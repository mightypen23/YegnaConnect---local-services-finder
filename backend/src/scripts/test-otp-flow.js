require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });

// Live test of the register + OTP verify flow against the running server
const BASE = 'http://localhost:3000/api';

(async () => {
  const phone = '+2519' + Math.floor(10000000 + Math.random() * 89999999);
  const email = `test_${Date.now()}@example.com`;

  console.log('--- 1) POST /auth/register ---');
  let reg;
  try {
    const res = await fetch(`${BASE}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        full_name: 'OTP Flow Tester',
        email,
        password: 'password123',
        phone_number: phone
      })
    });
    reg = await res.json();
    console.log('status:', res.status);
    console.log('response keys:', Object.keys(reg));
    console.log('dev_code:', reg.dev_code);
    console.log('phone_number:', reg.phone_number);
    console.log('token present:', !!reg.token);
  } catch (e) {
    console.error('register request failed:', e.message);
    return;
  }

  if (!reg.dev_code) {
    console.log('>>> PROBLEM: server did NOT return dev_code');
    return;
  }

  console.log('--- 2) POST /auth/otp/verify with dev code ---');
  try {
    const res = await fetch(`${BASE}/auth/otp/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phone_number: reg.phone_number, code: String(reg.dev_code) })
    });
    const data = await res.json();
    console.log('status:', res.status);
    console.log('token present:', !!data.token);
    console.log('user verified:', data.user ? data.user.is_verified : '(no user)');
  } catch (e) {
    console.error('verify request failed:', e.message);
  }
})();
