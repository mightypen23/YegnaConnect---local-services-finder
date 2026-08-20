const { Op } = require('sequelize');
const { ServiceProvider, User, VerificationBadge } = require('../models');
const creditService = require('./creditService');
const trustScoreService = require('./trustScoreService');

class AdminError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

// Only these badge types are admin-decided. trusted_provider is auto-granted
// by the trust engine (Task 26) and must never be touched here.
const ADMIN_BADGE_TYPES = ['identity_verified', 'certified_skill', 'assessed_skill'];
const VERIFICATION_DECISIONS = ['verified', 'rejected'];
const BADGE_DECISIONS = ['approved', 'rejected'];
const MAX_REASON_LENGTH = 500;

// Pure policy helpers (Task 29) — unit-testable without a database.
function validateVerificationDecision({ status, rejectionReason }) {
  const errors = [];
  if (!VERIFICATION_DECISIONS.includes(status)) {
    errors.push(`Status must be one of: ${VERIFICATION_DECISIONS.join(', ')}`);
  }
  if (status === 'rejected') {
    if (rejectionReason == null || String(rejectionReason).trim() === '') {
      errors.push('Rejection reason is required when rejecting');
    } else if (String(rejectionReason).trim().length > MAX_REASON_LENGTH) {
      errors.push(`Rejection reason must be at most ${MAX_REASON_LENGTH} characters`);
    }
  }
  return errors;
}

function validateBadgeDecision({ status, rejectionReason }) {
  const errors = [];
  if (!BADGE_DECISIONS.includes(status)) {
    errors.push(`Status must be one of: ${BADGE_DECISIONS.join(', ')}`);
  }
  if (status === 'rejected') {
    if (rejectionReason == null || String(rejectionReason).trim() === '') {
      errors.push('Rejection reason is required when rejecting');
    } else if (String(rejectionReason).trim().length > MAX_REASON_LENGTH) {
      errors.push(`Rejection reason must be at most ${MAX_REASON_LENGTH} characters`);
    }
  }
  return errors;
}

function validateGrantCredits({ amount, reason }) {
  const errors = creditService.validateCreditAmount(amount);
  if (reason != null && String(reason).trim().length > 255) {
    errors.push('Reason must be at most 255 characters');
  }
  return errors;
}

function isAdminBadgeType(badgeType) {
  return ADMIN_BADGE_TYPES.includes(badgeType);
}

async function listProviders({ verificationStatus, subscriptionStatus, limit = 50, offset = 0 } = {}) {
  const where = {};
  if (verificationStatus) where.verification_status = verificationStatus;
  if (subscriptionStatus) where.subscription_status = subscriptionStatus;
  return ServiceProvider.findAndCountAll({
    where,
    include: [
      {
        model: User,
        as: 'user',
        attributes: ['id', 'full_name', 'phone_number', 'email', 'role', 'created_at']
      }
    ],
    order: [['created_at', 'DESC']],
    limit,
    offset,
    distinct: true
  });
}

async function setProviderVerification({ providerId, status, rejectionReason }) {
  const errors = validateVerificationDecision({ status, rejectionReason });
  if (errors.length > 0) {
    throw new AdminError(400, errors[0]);
  }
  const provider = await ServiceProvider.findByPk(providerId);
  if (!provider) {
    throw new AdminError(404, 'Provider profile not found');
  }
  provider.verification_status = status;
  provider.verification_rejection_reason =
    status === 'rejected' ? String(rejectionReason).trim() : null;
  await provider.save();

  await trustScoreService.recalculateForProvider(providerId);
  await trustScoreService.maybeAutoGrantBadge(providerId);
  return provider;
}

async function listBadges({ status, limit = 50, offset = 0 } = {}) {
  const where = {};
  if (status) where.status = status;
  if (!status) {
    where.status = { [Op.in]: ['pending', 'under_review'] };
  }
  return VerificationBadge.findAndCountAll({
    where,
    include: [
      {
        model: ServiceProvider,
        as: 'provider',
        attributes: ['id', 'verification_status'],
        include: [
          {
            model: User,
            as: 'user',
            attributes: ['id', 'full_name', 'phone_number', 'email']
          }
        ]
      }
    ],
    order: [['created_at', 'ASC']],
    limit,
    offset,
    distinct: true
  });
}

async function decideBadge({ adminUserId, badgeId, status, rejectionReason }) {
  const errors = validateBadgeDecision({ status, rejectionReason });
  if (errors.length > 0) {
    throw new AdminError(400, errors[0]);
  }
  const badge = await VerificationBadge.findByPk(badgeId);
  if (!badge) {
    throw new AdminError(404, 'Verification badge not found');
  }
  if (!isAdminBadgeType(badge.badge_type)) {
    throw new AdminError(
      400,
      'trusted_provider badges are granted automatically and cannot be decided by an admin'
    );
  }
  badge.status = status;
  badge.rejection_reason = status === 'rejected' ? String(rejectionReason).trim() : null;
  badge.verified_by = adminUserId;
  badge.verified_at = new Date();
  await badge.save();

  const provider = await ServiceProvider.findByPk(badge.provider_id);
  if (provider && status === 'approved' && badge.badge_type === 'identity_verified') {
    provider.verification_status = 'verified';
    await provider.save();
  }

  await trustScoreService.recalculateForProvider(badge.provider_id);
  await trustScoreService.maybeAutoGrantBadge(badge.provider_id);
  return badge;
}

async function grantCredits({ adminUserId, providerId, amount, reason }) {
  const errors = validateGrantCredits({ amount, reason });
  if (errors.length > 0) {
    throw new AdminError(400, errors[0]);
  }
  return creditService.creditProvider(providerId, amount, {
    reason: reason && String(reason).trim() !== '' ? String(reason).trim() : 'admin:grant',
    performedBy: adminUserId
  });
}

module.exports = {
  listProviders,
  setProviderVerification,
  listBadges,
  decideBadge,
  grantCredits,
  validateVerificationDecision,
  validateBadgeDecision,
  validateGrantCredits,
  isAdminBadgeType,
  ADMIN_BADGE_TYPES,
  AdminError
};