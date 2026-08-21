require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');
const { User, ServiceProvider, Category, ProviderCategory, ProviderLocation, VerificationBadge } = require('../models');

const categories = [
  ['plumber', 'Plumber', 'plumbing'], ['electrician', 'Electrician', 'flash_on'],
  ['tvdish', 'TV/Dish', 'tv'], ['cleaning', 'Cleaning', 'cleaning_services'],
  ['painting', 'Painting', 'format_paint'], ['mechanic', 'Mechanic', 'build'],
  ['carpenter', 'Carpenter', 'handyman'], ['tutor', 'Tutor', 'school'],
  ['beauty', 'Beauty Services', 'content_cut'], ['transport', 'Moving / Transport', 'local_shipping']
];

async function seed() {
  await sequelize.authenticate();
  await sequelize.sync();
  const categoryRows = {};
  for (const [key, name, icon] of categories) {
    const [row] = await Category.findOrCreate({ where: { name }, defaults: { icon, description: `${name} services` } });
    categoryRows[key] = row;
  }
  const providers = [
    ['demo-solomon@yegna.local', 'Solomon Getaw', '+251911000001', 'Kality, Addis Ababa', 'Experienced TV and dish technician with over 6 years fixing signal issues and home installations.', ['tvdish', 'electrician']],
    ['demo-nardos@yegna.local', 'Nardos Tesfaye', '+251911000002', 'Bole, Addis Ababa', 'Professional electrician providing safe wiring, circuit repair, and light fitting.', ['electrician', 'plumber']],
    ['demo-abebe@yegna.local', 'Abebe Sheferaw', '+251911000003', 'Sarbet, Addis Ababa', 'Expert plumber handling emergency leaks, pipe replacement, and bathroom fittings.', ['plumber', 'cleaning']],
    ['demo-sitota@yegna.local', 'Sitota Tesfaw', '+251911000004', 'Kazanchis, Addis Ababa', 'Interior and exterior painter with clean, quality work.', ['painting', 'cleaning']]
  ];
  for (const [email, full_name, phone_number, address, bio, keys] of providers) {
    const [user] = await User.findOrCreate({ where: { email }, defaults: { full_name, email, phone_number, role: 'provider', is_verified: true } });
    if (!user.phone_number) await user.update({ phone_number });
    const [provider] = await ServiceProvider.findOrCreate({ where: { user_id: user.id }, defaults: { bio, trust_score: 4.5, verification_status: 'verified', credit_balance: 30 } });
    if (provider.credit_balance !== 30) await provider.update({ credit_balance: 30 });
    for (const key of keys) await ProviderCategory.findOrCreate({ where: { provider_id: provider.id, category_id: categoryRows[key].id }, defaults: { skill_level: 'expert' } });
    await ProviderLocation.findOrCreate({ where: { provider_id: provider.id }, defaults: { latitude: 9.0192, longitude: 38.7525, address, city: 'Addis Ababa', region: 'Addis Ababa' } });
    await VerificationBadge.findOrCreate({ where: { provider_id: provider.id, badge_type: 'identity_verified' }, defaults: { status: 'approved', verified_at: new Date() } });
  }
  console.log('Demo data seeded');
  await sequelize.close();
}
seed().catch((error) => { console.error(error); process.exitCode = 1; });
