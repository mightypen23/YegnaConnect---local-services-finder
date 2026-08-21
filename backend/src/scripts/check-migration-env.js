require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });

const localKeys = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD'];
const neonUrl = process.env.NEON_DATABASE_URL || process.env.DATABASE_URL;

console.log(JSON.stringify({
  localConfigured: localKeys.every((key) => typeof process.env[key] === 'string' && process.env[key].length > 0),
  missingLocalKeys: localKeys.filter((key) => !process.env[key]),
  neonConfigured: typeof neonUrl === 'string' && neonUrl.length > 0,
  neonSslConfigured: typeof neonUrl === 'string' && (neonUrl.includes('sslmode=require') || neonUrl.includes('ssl=true')),
  localPasswordLength: process.env.DB_PASSWORD?.length || 0
}, null, 2));
