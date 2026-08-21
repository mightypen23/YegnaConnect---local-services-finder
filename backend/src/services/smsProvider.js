const SMS_ENDPOINT = process.env.SMS_API_URL || 'https://smsethiopia.com/api/sms/send';
const REQUEST_TIMEOUT_MS = 10000;

class SmsError extends Error {}

// SMSEthiopia expects an MSISDN without the leading '+', e.g. 251911234567.
function toMsisdn(phone) {
  return String(phone).replace(/\D/g, '');
}

async function sendSms(phone, text) {
  const apiKey = process.env.SMS_API_KEY;
  if (!apiKey) {
    throw new SmsError('SMS_API_KEY is not configured');
  }

  let response;
  try {
    response = await fetch(SMS_ENDPOINT, {
      method: 'POST',
      headers: {
        KEY: apiKey,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ msisdn: toMsisdn(phone), text }),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS)
    });
  } catch (err) {
    throw new SmsError(`Could not reach the SMS gateway: ${err.message}`);
  }

  const raw = await response.text();
  let payload;
  try {
    payload = JSON.parse(raw);
  } catch {
    payload = { message: raw };
  }

  if (!response.ok || (payload.status && payload.status !== 'success')) {
    throw new SmsError(payload.message || `SMS gateway returned ${response.status}`);
  }

  return { delivered: true, description: payload.message };
}

async function sendOtp(phone, code) {
  const text = `Your YegnaConnect verification code is ${code}. It expires in 5 minutes.`;

  if (process.env.NODE_ENV !== 'production') {
    console.log(`[MOCK SMS] To ${phone}: ${text}`);
    return { delivered: true, mock: true };
  }

  return sendSms(phone, text);
}

module.exports = { sendOtp, sendSms, SmsError };