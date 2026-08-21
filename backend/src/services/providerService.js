const { Op } = require('sequelize');
const { sequelize } = require('../config/database');
const { Category, ProviderLocation, User, VerificationBadge } = require('../models');
const ProviderRepository = require('../repositories/ProviderRepository');
const creditService = require('./creditService');

const providerRepository = new ProviderRepository();

// One-time credit bonus granted to every new provider profile.
const SIGNUP_CREDIT_BONUS = 30;

class ProviderError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

const CATEGORY_INCLUDE = [
  {
    model: Category,
    as: 'categories',
    through: { attributes: ['skill_level'] }
  }
];

const LOCATION_INCLUDE = [
  {
    model: ProviderLocation,
    as: 'locations',
    required: false,
    separate: true,
    order: [['created_at', 'DESC']],
    limit: 1
  }
];

const USER_INCLUDE = {
  model: User,
  as: 'user',
  attributes: ['full_name', 'phone_number']
};

const BADGE_INCLUDE = {
  model: VerificationBadge,
  as: 'badges',
  required: false,
  where: { status: 'approved' },
  attributes: ['badge_type']
};

const DIRECTORY_INCLUDE = [
  ...CATEGORY_INCLUDE,
  ...LOCATION_INCLUDE,
  USER_INCLUDE,
  BADGE_INCLUDE
];

async function getById(id, userId) {
  const provider = await providerRepository.findById(id, {
    include: [...CATEGORY_INCLUDE, ...LOCATION_INCLUDE]
  });
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  if (provider.user_id !== userId) {
    throw new ProviderError(403, 'You do not have access to this provider profile');
  }
  return provider;
}

async function getByUserId(userId) {
  const provider = await providerRepository.findByUserId(userId, {
    include: [...CATEGORY_INCLUDE, ...LOCATION_INCLUDE]
  });
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  return provider;
}

async function listDirectory() {
  return providerRepository.findAll({
    include: DIRECTORY_INCLUDE,
    order: [['created_at', 'DESC']]
  });
}

async function listChanged({ since }) {
  const where = since ? { updated_at: { [Op.gt]: since } } : {};
  return providerRepository.findAll({
    where,
    include: DIRECTORY_INCLUDE,
    order: [['updated_at', 'ASC']]
  });
}

async function getPublicById(id) {
  const provider = await providerRepository.findById(id, {
    include: DIRECTORY_INCLUDE
  });
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  return provider;
}

async function createProvider(user, { id, bio, categories, location, fullName, phoneNumber }) {
  const existing = await providerRepository.findByUserId(user.id);
  if (existing) {
    throw new ProviderError(409, 'Provider profile already exists for this account');
  }

  const categoryInputs = Array.isArray(categories) ? categories : [];

  const provider = await sequelize.transaction(async (t) => {
    const created = await providerRepository.createProvider(
      { id, user_id: user.id, bio },
      { transaction: t }
    );
    await providerRepository.addCategories(created.id, categoryInputs, { transaction: t });
    if (location) {
      const locData = typeof location === 'string'
        ? { address: location, city: location, region: 'Addis Ababa', latitude: 9.0192, longitude: 38.7525 }
        : {
            address: location.address || location.city || 'Addis Ababa',
            city: location.city || location.address || 'Addis Ababa',
            region: location.region || 'Addis Ababa',
            latitude: location.latitude ?? 9.0192,
            longitude: location.longitude ?? 38.7525
          };
      await providerRepository.updateLocation(created.id, locData, { transaction: t });
    }
    await creditService.creditProvider(
      created.id, SIGNUP_CREDIT_BONUS,
      'Signup bonus', null, null,
      { transaction: t }
    );
    user.role = 'provider';
    if (fullName) user.full_name = fullName;
    if (phoneNumber) user.phone_number = phoneNumber;
    await user.save({ transaction: t });
    return created;
  });

  return getById(provider.id, user.id);
}

async function updateProvider(id, userId, { bio, categories }) {
  const provider = await providerRepository.findById(id);
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  if (provider.user_id !== userId) {
    throw new ProviderError(403, 'You do not have access to this provider profile');
  }

  await sequelize.transaction(async (t) => {
    if (bio !== undefined) {
      provider.bio = bio;
      await provider.save({ transaction: t });
    }
    if (categories !== undefined) {
      const categoryInputs = Array.isArray(categories) ? categories : [];
      await providerRepository.replaceCategories(id, categoryInputs, { transaction: t });
    }
  });

  return getById(id, userId);
}

async function setLocation(id, userId, location) {
  const provider = await providerRepository.findById(id);
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  if (provider.user_id !== userId) {
    throw new ProviderError(403, 'You do not have access to this provider profile');
  }

async function submitVerificationBadge(userId, { badgeType = 'identity_verified', evidence, evidenceUrl }) {
  const provider = await providerRepository.findByUserId(userId);
  if (!provider) {
    throw new ProviderError(404, 'Provider profile not found');
  }
  const existing = await VerificationBadge.findOne({
    where: { provider_id: provider.id, badge_type: badgeType }
  });
  if (existing) {
    existing.evidence = evidence;
    if (evidenceUrl) existing.evidence_url = evidenceUrl;
    existing.status = 'pending';
    await existing.save();
    return existing;
  }
  return VerificationBadge.create({
    provider_id: provider.id,
    badge_type: badgeType,
    evidence,
    evidence_url: evidenceUrl,
    status: 'pending'
  });
}

module.exports = { createProvider, updateProvider, getById, getByUserId, listDirectory, listChanged, getPublicById, setLocation, submitVerificationBadge, DIRECTORY_INCLUDE, ProviderError };}