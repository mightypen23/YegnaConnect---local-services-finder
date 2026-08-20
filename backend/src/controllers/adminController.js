const { body, param, query, validationResult } = require('express-validator');
const {
  listProviders,
  setProviderVerification,
  listBadges,
  decideBadge,
  grantCredits,
  AdminError
} = require('../services/adminService');
const {
  createSubscription,
  SubscriptionError
} = require('../services/subscriptionService');
const {
  sanitizePlan,
  listAdmin,
  create: createPlanHandler,
  update: updatePlanHandler
} = require('./subscriptionPlanController');
const {
  listActivePlans
} = require('../services/subscriptionPlanService');
const { sanitizeCreditTransaction } = require('./creditController');

function asyncHandler(fn) {
  return (req, res, next) => {
    fn(req, res, next).catch((err) => {
      if (err instanceof AdminError || err instanceof SubscriptionError) {
        return res.status(err.status).json({ error: err.message });
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
  return {
    id: p.id,
    user: p.user
      ? {
          id: p.user.id,
          full_name: p.user.full_name,
          phone_number: p.user.phone_number,
          email: p.user.email,
          role: p.user.role,
          created_at: p.user.created_at
        }
      : null,
    bio: p.bio,
    credit_balance: p.credit_balance,
    trust_score: p.trust_score == null ? null : Number(p.trust_score),
    verification_status: p.verification_status,
    verification_rejection_reason: p.verification_rejection_reason ?? null,
    availability_status: p.availability_status,
    subscription_status: p.subscription_status,
    created_at: p.created_at,
    updated_at: p.updated_at
  };
}

function sanitizeBadge(badge) {
  const b = badge.toJSON ? badge.toJSON() : badge;
  return {
    id: b.id,
    provider_id: b.provider_id,
    provider_name: b.provider?.user?.full_name ?? null,
    badge_type: b.badge_type,
    evidence: b.evidence,
    evidence_url: b.evidence_url,
    status: b.status,
    rejection_reason: b.rejection_reason,
    verified_by: b.verified_by,
    verified_at: b.verified_at,
    created_at: b.created_at
  };
}

async function sanitizeSubscription(subscription) {
  const row = subscription.toJSON ? subscription.toJSON() : subscription;
  return {
    id: row.id,
    provider_id: row.provider_id,
    plan_name: row.plan_name,
    credits: row.credits,
    amount_paid: row.amount_paid == null ? null : Number(row.amount_paid),
    currency: row.currency,
    starts_at: row.starts_at,
    expires_at: row.expires_at,
    status: row.status,
    created_at: row.created_at
  };
}

const listProviderValidators = [
  query('verification_status')
    .optional()
    .isIn(['pending', 'verified', 'rejected'])
    .withMessage('Invalid verification status'),
  query('subscription_status')
    .optional()
    .isIn(['inactive', 'active', 'expired'])
    .withMessage('Invalid subscription status'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('offset')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Offset must be a non-negative integer')
];

const verificationValidators = [
  param('providerId').isUUID().withMessage('Invalid provider id'),
  body('status')
    .isIn(['verified', 'rejected'])
    .withMessage('Status must be approved or rejected'),
  body('rejection_reason')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 500 })
    .withMessage('Rejection reason must be at most 500 characters')
];

const creditsValidators = [
  param('providerId').isUUID().withMessage('Invalid provider id'),
  body('amount')
    .isInt({ min: 1 })
    .withMessage('Amount must be a positive integer'),
  body('reason')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 255 })
    .withMessage('Reason must be at most 255 characters')
];

const subscriptionValidators = [
  body('provider_id').isUUID().withMessage('Invalid provider id'),
  body('plan_id').isUUID().withMessage('Invalid plan id'),
  body('amount_paid')
    .optional({ nullable: true })
    .isFloat({ min: 0 })
    .withMessage('Amount paid must be a non-negative number'),
  body('starts_at')
    .optional({ nullable: true })
    .isISO8601()
    .withMessage('starts_at must be a valid ISO date'),
  body('expires_at')
    .optional({ nullable: true })
    .isISO8601()
    .withMessage('expires_at must be a valid ISO date')
];

const badgeListValidators = [
  query('status')
    .optional()
    .isIn(['pending', 'under_review', 'approved', 'rejected'])
    .withMessage('Invalid badge status'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('offset')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Offset must be a non-negative integer')
];

const badgeDecisionValidators = [
  param('badgeId').isUUID().withMessage('Invalid badge id'),
  body('status')
    .isIn(['approved', 'rejected'])
    .withMessage('Status must be approved or rejected'),
  body('rejection_reason')
    .optional({ nullable: true })
    .trim()
    .isLength({ max: 500 })
    .withMessage('Rejection reason must be at most 500 characters')
];

const list = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { rows, count } = await listProviders({
    verificationStatus: req.query.verification_status,
    subscriptionStatus: req.query.subscription_status,
    limit: req.query.limit ? Number(req.query.limit) : 50,
    offset: req.query.offset ? Number(req.query.offset) : 0
  });
  res.json({ providers: rows.map(sanitizeProvider), total: count });
});

const setVerification = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const provider = await setProviderVerification({
    adminUserId: req.user.id,
    providerId: req.params.providerId,
    status: req.body.status,
    rejectionReason: req.body.rejection_reason
  });
  res.json({ provider: sanitizeProvider(provider) });
});

const grantCreditsHandler = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const result = await grantCredits({
    adminUserId: req.user.id,
    providerId: req.params.providerId,
    amount: req.body.amount,
    reason: req.body.reason
  });
  res.json({
    balance: result.balance,
    transaction: sanitizeCreditTransaction(result.transaction)
  });
});

const createSubscriptionHandler = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const plans = await listActivePlans();
  const plan = plans.find((p) => p.id === req.body.plan_id);
  const subscription = await createSubscription({
    adminUserId: req.user.id,
    providerId: req.body.provider_id,
    plan,
    amountPaid: req.body.amount_paid,
    startsAt: req.body.starts_at,
    expiresAt: req.body.expires_at
  });
  res.status(201).json({ subscription: await sanitizeSubscription(subscription) });
});

const listBadgesHandler = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const { rows, count } = await listBadges({
    status: req.query.status,
    limit: req.query.limit ? Number(req.query.limit) : 50,
    offset: req.query.offset ? Number(req.query.offset) : 0
  });
  res.json({ badges: rows.map(sanitizeBadge), total: count });
});

const decideBadgeHandler = asyncHandler(async (req, res) => {
  if (!requireValid(req, res)) return;
  const badge = await decideBadge({
    adminUserId: req.user.id,
    badgeId: req.params.badgeId,
    status: req.body.status,
    rejectionReason: req.body.rejection_reason
  });
  res.json({ badge: sanitizeBadge(badge) });
});

module.exports = {
  listProviderValidators,
  verificationValidators,
  creditsValidators,
  subscriptionValidators,
  badgeListValidators,
  badgeDecisionValidators,
  sanitizeProvider,
  sanitizeBadge,
  list,
  setVerification,
  grantCreditsHandler,
  createSubscriptionHandler,
  listBadgesHandler,
  decideBadgeHandler,
  planList: listAdmin,
  planCreate: createPlanHandler,
  planUpdate: updatePlanHandler,
  planSanitizer: sanitizePlan
};