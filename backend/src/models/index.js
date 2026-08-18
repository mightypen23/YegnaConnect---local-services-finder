const User = require('./User');
const ServiceProvider = require('./ServiceProvider');
const Category = require('./Category');
const ProviderCategory = require('./ProviderCategory');
const ProviderLocation = require('./ProviderLocation');
const Review = require('./Review');
const VerificationBadge = require('./VerificationBadge');
const ServiceRequest = require('./ServiceRequest');
const Subscription = require('./Subscription');
const CreditTransaction = require('./CreditTransaction');
const SyncQueue = require('./SyncQueue');

// Define all associations here (single source of truth)

// User <-> ServiceProvider
User.hasOne(ServiceProvider, { foreignKey: 'user_id', as: 'provider' });
ServiceProvider.belongsTo(User, { foreignKey: 'user_id', as: 'user' });

// ServiceProvider <-> Category (many-to-many through ProviderCategory)
ServiceProvider.belongsToMany(Category, { through: ProviderCategory, foreignKey: 'provider_id', as: 'categories' });
Category.belongsToMany(ServiceProvider, { through: ProviderCategory, foreignKey: 'category_id', as: 'providers' });

// ProviderCategory belongs to both
ProviderCategory.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
ProviderCategory.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });

// ProviderLocation belongs to ServiceProvider
ProviderLocation.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
ServiceProvider.hasMany(ProviderLocation, { foreignKey: 'provider_id', as: 'locations' });

// Review belongs to ServiceProvider and User
Review.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
Review.belongsTo(User, { foreignKey: 'customer_id', as: 'customer' });
ServiceProvider.hasMany(Review, { foreignKey: 'provider_id', as: 'reviews' });
User.hasMany(Review, { foreignKey: 'customer_id', as: 'reviews' });

// VerificationBadge belongs to ServiceProvider and User (verifier)
VerificationBadge.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
VerificationBadge.belongsTo(User, { foreignKey: 'verified_by', as: 'verifier' });
ServiceProvider.hasMany(VerificationBadge, { foreignKey: 'provider_id', as: 'badges' });
User.hasMany(VerificationBadge, { foreignKey: 'verified_by', as: 'verified_badges' });

// ServiceRequest belongs to User, ServiceProvider, and Category
ServiceRequest.belongsTo(User, { foreignKey: 'customer_id', as: 'customer' });
ServiceRequest.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
ServiceRequest.belongsTo(Category, { foreignKey: 'category_id', as: 'category' });
User.hasMany(ServiceRequest, { foreignKey: 'customer_id', as: 'requests' });
ServiceProvider.hasMany(ServiceRequest, { foreignKey: 'provider_id', as: 'requests' });
Category.hasMany(ServiceRequest, { foreignKey: 'category_id', as: 'requests' });

// Review belongs to ServiceRequest (optional)
Review.belongsTo(ServiceRequest, { foreignKey: 'request_id', as: 'request' });
ServiceRequest.hasMany(Review, { foreignKey: 'request_id', as: 'reviews' });

// Subscription belongs to ServiceProvider
Subscription.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
ServiceProvider.hasMany(Subscription, { foreignKey: 'provider_id', as: 'subscriptions' });

// CreditTransaction belongs to ServiceProvider
CreditTransaction.belongsTo(ServiceProvider, { foreignKey: 'provider_id', as: 'provider' });
ServiceProvider.hasMany(CreditTransaction, { foreignKey: 'provider_id', as: 'creditTransactions' });

module.exports = {
  User,
  ServiceProvider,
  Category,
  ProviderCategory,
  ProviderLocation,
  Review,
  VerificationBadge,
  ServiceRequest,
  Subscription,
  CreditTransaction,
  SyncQueue
};