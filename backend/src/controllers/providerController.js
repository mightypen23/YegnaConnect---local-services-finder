const { body, param, validationResult } = require('express-validator');
const { ForeignKeyConstraintError, UniqueConstraintError } = require('sequelize');
const {
  createProvider,
  getByUserId,
  getPublicById,
  listDirectory,
  updateProvider,
  setLocation,
  ProviderError
} = require('../services/providerService');

function asyncHandler(fn) {
  return (req, res, next) => {
    fn(req, res, next).catch((err) => {
      if (err instanceof ProviderError) {
        return res.status(err.status).json({ error: err.message });
      }
      if (err instanceof UniqueConstraintError) {
        return res.status(409).json({ error: 'Provider profile already exists for this account' });
      }
      if (err instanceof ForeignKeyConstraintError) {
        return res.status(400).json({ error: 'One or more categories do not exist' });
      }
      return next(err);
    });
  };
}

function requireValid(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(400).json({ error: errors.array()[0].msg });
    return false;
  }
  return true;
}

function sanitizeProvider(provider) {
  const p = provider.toJSON ? provider.toJSON() : provider;
  const categories = Array.isArray(p.categories)
    ? p.categories.map((c) => ({
        id: c.id,
        name: c.name,
        name_amharic: c.name_amharic,
        icon: c.icon,
        skill_level: c.ProviderCategory?.skill_level ?? 'intermediate'
      }))
    : [];
  const latestLocation = Array.isArray(p.locations) && p.locations.length > 0
    ? p.locations[0]
    : null;
  return {
    id: p.id,
    user_id: p.user_id,
    bio: p.bio,
    credit_balance: p.credit_balance,
    trust_score: p.trust_score == null ? null : Number(p.trust_score),
    verification_status: p.verification_status,
    availability_status: p.availability_status,
    subscription_status: p.subscription_status,
    categories,
    location: latestLocation
      ? {
          latitude: Number(latestLocation.latitude),
          longitude: Number(latestLocation.longitude),
          accuracy:
            latestLocation.accuracy == null
              ? null
              : Number(latestLocation.accuracy),
          address: latestLocation.address,
          city: latestLocation.city,
          region: latestLocation.region
        }
      : null,
    created_at: p.created_at,
    updated_at: p.updated_at
  };
}

function sanitizePublicProvider(provider) {
  const p = provider.toJSON ? provider.toJSON() : provider;
  const categories = Array.isArray(p.categories)
    ? p.categories.map((c) => ({
        id: c.id,
        name: c.name,
        name_amharic: c.name_amharic,
        icon: c.icon,
        skill_level: c.ProviderCategory?.skill_level ?? 'intermediate'
      }))
    : [];
  const latestLocation = Array.isArray(p.locations) && p.locations.length > 0
    ? p.locations[0]
    : null;
  return {
    id: p.id,
    full_name: p.user?.full_name ?? null,
    // Public directory entries do not expose phone numbers. Contact details
    // are returned only through an accepted request flow.
    phone_number: null,
    bio: p.bio,
    trust_score: p.trust_score == null ? null : Number(p.trust_score),
    verification_status: p.verification_status,
    availability_status: p.availability_status,
    categories,
    badges: Array.isArray(p.badges) ? p.badges.map((b) => b.badge_type) : [],
    location: latestLocation
      ? {
          latitude: Number(latestLocation.latitude),
          longitude: Number(latestLocation.longitude),
          accuracy:
            latestLocation.accuracy == null
              ? null
              : Number(latestLocation.accuracy),
          address: latestLocation.address,
          city: latestLocation.city,
          region: latestLocation.region
        }
      : null,
    created_at: p.created_at,
    updated_at: p.updated_at
  };
}

const createProviderValidators = [
  body('full_name').optional().trim().notEmpty().withMessage('Full name cannot be empty'),
  body('phone_number').optional().trim().isLength({ min: 7, max: 30 }).withMessage('Invalid phone number'),
  body('bio')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Bio must be at most 1000 characters'),
  body('categories')
    .isArray({ min: 1 })
    .withMessage('Select at least one service category'),
  body('categories.*.id')
    .isUUID()
    .withMessage('Invalid category id'),
  body('categories.*.skill_level')
    .optional({ values: 'falsy' })
    .isIn(['beginner', 'intermediate', 'expert'])
    .withMessage('Invalid skill level')
];

const create = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const provider = await createProvider(req.user, {
    bio: req.body.bio,
    categories: req.body.categories,
    location: req.body.location,
    fullName: req.body.full_name,
    phoneNumber: req.body.phone_number
  });
  res.status(201).json({ provider: sanitizeProvider(provider) });
});

const getProviderValidators = [
  param('id').isUUID().withMessage('Invalid provider id')
];

const updateValidators = [
  param('id').isUUID().withMessage('Invalid provider id'),
  body('bio')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 1000 })
    .withMessage('Bio must be at most 1000 characters'),
  body('categories')
    .optional()
    .isArray({ min: 1 })
    .withMessage('Select at least one service category'),
  body('categories.*.id')
    .isUUID()
    .withMessage('Invalid category id'),
  body('categories.*.skill_level')
    .optional({ values: 'falsy' })
    .isIn(['beginner', 'intermediate', 'expert'])
    .withMessage('Invalid skill level')
];

const getPublicOne = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const provider = await getPublicById(req.params.id);
  res.json({ provider: sanitizePublicProvider(provider) });
});

const list = asyncHandler(async (req, res) => {
  const providers = await listDirectory();
  res.json({ providers: providers.map(sanitizePublicProvider) });
});

const getMe = asyncHandler(async (req, res) => {
  const provider = await getByUserId(req.user.id);
  res.json({ provider: sanitizeProvider(provider) });
});

const update = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const provider = await updateProvider(req.params.id, req.user.id, {
    bio: req.body.bio,
    categories: req.body.categories
  });
  res.json({ provider: sanitizeProvider(provider) });
});

const locationValidators = [
  param('id').isUUID().withMessage('Invalid provider id'),
  body('latitude')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Latitude must be between -90 and 90'),
  body('longitude')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Longitude must be between -180 and 180'),
  body('accuracy')
    .optional({ nullable: true })
    .isFloat({ min: 0 })
    .withMessage('Accuracy must be a non-negative number'),
  body('address')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 500 })
    .withMessage('Address must be at most 500 characters'),
  body('city')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 100 })
    .withMessage('City must be at most 100 characters'),
  body('region')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 100 })
    .withMessage('Region must be at most 100 characters')
];

const setLocationHandler = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const provider = await setLocation(req.params.id, req.user.id, {
    latitude: req.body.latitude,
    longitude: req.body.longitude,
    accuracy: req.body.accuracy ?? null,
    address: req.body.address ?? null,
    city: req.body.city ?? null,
    region: req.body.region ?? null
  });
  res.json({ provider: sanitizeProvider(provider) });
});

module.exports = {
  createProviderValidators,
  getProviderValidators,
  updateValidators,
  locationValidators,
  sanitizeProvider,
  sanitizePublicProvider,
  create,
  getPublicOne,
  list,
  getMe,
  update,
  setLocationHandler
};
