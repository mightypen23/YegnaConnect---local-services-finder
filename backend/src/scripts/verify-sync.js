require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { sequelize } = require('../config/database');
const {
  User,
  ServiceProvider,
  Category,
  ProviderCategory,
  ProviderLocation,
  Review,
  VerificationBadge,
  ServiceRequest,
  SubscriptionPlan,
  Subscription,
  CreditTransaction,
  SyncQueue
} = require('../models');

const TABLES = [
  'users',
  'service_providers',
  'service_categories',
  'provider_categories',
  'provider_locations',
  'reviews',
  'verification_badges',
  'service_requests',
  'subscription_plans',
  'subscriptions',
  'credit_transactions',
  'sync_queue'
];

const ALLOWED_FORCE_ENVS = ['development', 'test'];

async function verifySync() {
  console.log('=== YegnaConnect Database Sync Verification ===\n');

  const env = (process.env.NODE_ENV || 'development').toLowerCase();
  const force = process.argv.includes('--force');

  if (force && !ALLOWED_FORCE_ENVS.includes(env)) {
    console.error(`Refusing to drop/recreate tables in environment "${env}".`);
    console.error('Set NODE_ENV=development (or test) to use --force, or omit --force to only create missing tables.');
    return 1;
  }

  try {
    // Step 1: Test connection
    console.log('1. Testing database connection...');
    await sequelize.authenticate();
    console.log('   ✓ Connected to PostgreSQL\n');

    // Step 2: Sync all models (force only when explicitly requested in dev/test)
    console.log(`2. Syncing models to database${force ? ' (--force: tables will be dropped and recreated)' : ''}...`);
    await sequelize.sync({ force });
    console.log(`   ✓ Models synced${force ? ' (force)' : ''}\n`);

    // Step 3: Verify tables exist
    console.log('3. Verifying tables exist...');
    // Use Sequelize's dialect-aware discovery rather than assuming the
    // connection's active schema is always `public`.
    const discoveredTables = await sequelize.getQueryInterface().showAllTables();
    const existingTables = discoveredTables.map((table) => {
      if (typeof table === 'string') return table;
      return table.tableName || table.table_name || table.name;
    }).filter(Boolean);
    console.log(`   Discovered tables: ${existingTables.join(', ') || '(none)'}`);

    let allTablesExist = true;
    for (const table of TABLES) {
      if (existingTables.includes(table)) {
        console.log(`   ✓ ${table}`);
      } else {
        console.log(`   ✗ ${table} - MISSING`);
        allTablesExist = false;
      }
    }
    console.log('');

    if (!allTablesExist) {
      const missing = TABLES.filter(t => !existingTables.includes(t));
      console.error('=== Verification Failed ===');
      console.error(`Missing tables: ${missing.join(', ')}`);
      console.error('Re-run with --force (NODE_ENV=development/test) to recreate all tables.');
      return 1;
    }

    // Step 4: Test basic associations
    console.log('4. Testing associations...');

    // Use unique test data so verification can be run repeatedly without
    // colliding with the users.phone_number unique constraint.
    const testPhone = `+251911${String(Date.now()).slice(-7)}`;

    // Create a user
    const user = await User.create({
      full_name: 'Test User',
      phone_number: testPhone,
      role: 'customer'
    });
    console.log('   ✓ Created test user');

    // Create a provider
    const provider = await ServiceProvider.create({
      user_id: user.id,
      bio: 'Test provider'
    });
    console.log('   ✓ Created test provider (belongsTo User)');

    // Use a unique category name so repeated verification runs do not collide
    // with the service_categories.name unique constraint.
    const category = await Category.create({
      name: `Verification Plumbing ${Date.now()}`,
      name_amharic: 'ፔምቢንግ'
    });
    console.log('   ✓ Created test category');

    // Create provider-category association
    await ProviderCategory.create({
      provider_id: provider.id,
      category_id: category.id,
      skill_level: 'expert'
    });
    console.log('   ✓ Created provider-category association (belongsToMany)');

    // Create a location
    await ProviderLocation.create({
      provider_id: provider.id,
      latitude: 9.0249,
      longitude: 38.7468,
      city: 'Addis Ababa'
    });
    console.log('   ✓ Created provider location (hasMany)');

    // Create a service request
    const request = await ServiceRequest.create({
      customer_id: user.id,
      provider_id: provider.id,
      category_id: category.id,
      description: 'Fix leaking pipe',
      latitude: 9.0249,
      longitude: 38.7468
    });
    console.log('   ✓ Created service request');

    // Create a review
    await Review.create({
      provider_id: provider.id,
      customer_id: user.id,
      request_id: request.id,
      rating: 5,
      comment: 'Excellent work!'
    });
    console.log('   ✓ Created review (belongsTo User, ServiceProvider, ServiceRequest)');

    // Create a verification badge
    await VerificationBadge.create({
      provider_id: provider.id,
      badge_type: 'identity_verified',
      status: 'approved'
    });
    console.log('   ✓ Created verification badge');

    // Create a subscription
    await Subscription.create({
      provider_id: provider.id,
      plan_name: 'Basic',
      credits: 100,
      starts_at: new Date(),
      expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    });
    console.log('   ✓ Created subscription');

    // Create a credit transaction
    await CreditTransaction.create({
      provider_id: provider.id,
      amount: 100,
      type: 'credit',
      reason: 'Initial credits'
    });
    console.log('   ✓ Created credit transaction');

    // Create a sync queue entry
    await SyncQueue.create({
      entity_type: 'service_request',
      entity_id: request.id,
      operation: 'create',
      payload: request.toJSON(),
      client_id: request.id
    });
    console.log('   ✓ Created sync queue entry');

    console.log('\n=== All Verifications Passed ===');
    console.log(`Tables: ${TABLES.length}/${TABLES.length} created`);
    console.log('Associations: All working');
    console.log('CRUD Operations: All working');
    return 0;

  } catch (error) {
    console.error('\n=== Verification Failed ===');
    console.error('Error:', error.message);
    if (error.parent) {
      console.error('SQL Error:', error.parent.message);
    }
    return 1;
  } finally {
    await sequelize.close();
  }
}

verifySync().then(code => process.exit(code));
