require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');
const { Category } = require('../models');

// Icon keys map to IconData lookups on the Flutter side (see lib/models/category.dart).
const CATEGORIES = [
  { name: 'Plumber', name_amharic: 'የቧንቧ ሰራተኛ', icon: 'plumbing', description: 'Pipe repair, leak fixes, and bathroom installations.' },
  { name: 'Electrician', name_amharic: 'ኤሌክትሪክ ባለሙያ', icon: 'electrician', description: 'Wiring, circuit repair, and light fittings.' },
  { name: 'Tv/Dish', name_amharic: 'ቲቪ/ዲሽ', icon: 'tv', description: 'TV and satellite dish installation and repair.' },
  { name: 'Cleaning', name_amharic: 'ጽዳት', icon: 'cleaning', description: 'Home and office cleaning services.' },
  { name: 'Painting', name_amharic: 'ቀለም ቀቢ', icon: 'painting', description: 'Interior and exterior painting.' },
  { name: 'Mechanic', name_amharic: 'መካኒክ', icon: 'mechanic', description: 'Vehicle repair and maintenance.' },
  { name: 'Carpenter', name_amharic: 'አናጺ', icon: 'carpenter', description: 'Furniture and woodwork repair.' },
  { name: 'Tutor', name_amharic: 'አስተማሪ', icon: 'tutor', description: 'Private tutoring services.' },
  { name: 'Beauty Services', name_amharic: 'ውበት አገልግሎት', icon: 'beauty', description: 'Hair, nails, and beauty treatments.' },
  { name: 'Moving / Transport', name_amharic: 'መጓጓዣ', icon: 'transport', description: 'Moving and transport services.' },
];

async function seedCategories() {
  console.log('=== Seeding service categories ===\n');
  await sequelize.authenticate();

  for (const category of CATEGORIES) {
    const [record, created] = await Category.findOrCreate({
      where: { name: category.name },
      defaults: category,
    });
    console.log(`   ${created ? 'created' : 'exists '} - ${record.name}`);
  }

  console.log('\nDone.');
}

seedCategories()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seeding failed:', err);
    process.exit(1);
  });
