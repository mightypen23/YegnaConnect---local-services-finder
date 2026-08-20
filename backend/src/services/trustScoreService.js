const {
  ServiceProvider,
  Review,
  ServiceRequest,
  VerificationBadge
} = require('../models');
const { fn, col } = require('sequelize');

// Task 25 — Trust score engine (0–5).
//
// Addressable sources of truth:
//   - average review rating  (weight 60%)
//   - verification status   (weight 15%: verified -> 1.0, else 0)
//   - approved badges       (weight 15%: number of approved badge types / 4, capped)
//   - completion rate       (weight 10%: completed / (completed + cancelled))
//
// Each component is normalized to 0..1, blended with the weights (which sum
// to 1), then scaled to 0..5 and clamped. Without the normalization the blend
// could never exceed 3.4, which would make the trusted_provider threshold
// (4.0) unreachable.
const WEIGHTS = {
  rating: 0.6,
  verification: 0.15,
  badges: 0.15,
  completion: 0.1
};

const BADGE_TYPES = ['identity_verified', 'certified_skill', 'assessed_skill', 'trusted_provider'];

// Task 26 — trusted_provider is auto-granted from trust score (server-controlled).
const TRUSTED_PROVIDER_THRESHOLD = 4.0;

function shouldGrantTrustedProvider(trustScore) {
  return trustScore != null && Number(trustScore) >= TRUSTED_PROVIDER_THRESHOLD;
}

// Pure computation, unit-testable without a database.
function computeTrustScore({
  averageRating = 0,
  reviewCount = 0,
  verificationStatus = 'pending',
  approvedBadgeCount = 0,
  completed = 0,
  cancelled = 0
} = {}) {
  // Average rating contributes only when there is at least one review.
  const ratingComponent =
    reviewCount > 0 ? Math.min(Math.max(averageRating, 0), 5) / 5 : 0;

  const verificationComponent =
    verificationStatus === 'verified' ? 1 : 0;

  const badgeRatio = Math.min(approvedBadgeCount / BADGE_TYPES.length, 1);
  const badgeComponent = badgeRatio;

  const totalRequests = completed + cancelled;
  const completionComponent =
    totalRequests > 0 ? completed / totalRequests : 0;

  const blended =
    ratingComponent * WEIGHTS.rating +
    verificationComponent * WEIGHTS.verification +
    badgeComponent * WEIGHTS.badges +
    completionComponent * WEIGHTS.completion;

  const score = Math.min(Math.max(blended, 0), 1) * 5;
  return Math.round(score * 100) / 100;
}

async function getStatsForProvider(providerId) {
  const [ratingRow] = await Review.findAll({
    where: { provider_id: providerId },
    attributes: [
      [fn('AVG', col('rating')), 'avg_rating'],
      [fn('COUNT', col('id')), 'review_count']
    ],
    raw: true
  });

  const provider = await ServiceProvider.findByPk(providerId, {
    attributes: ['verification_status']
  });

  const completed = await ServiceRequest.count({
    where: { provider_id: providerId, status: 'completed' }
  });
  const cancelled = await ServiceRequest.count({
    where: { provider_id: providerId, status: 'cancelled' }
  });
  const approvedBadgeCount = await VerificationBadge.count({
    where: { provider_id: providerId, status: 'approved' }
  });

  return {
    averageRating: ratingRow?.avg_rating == null ? 0 : Number(ratingRow.avg_rating),
    reviewCount: Number(ratingRow?.review_count ?? 0),
    verificationStatus: provider?.verification_status ?? 'pending',
    approvedBadgeCount,
    completed,
    cancelled
  };
}

async function recalculateForProvider(providerId) {
  if (!providerId) return null;
  const stats = await getStatsForProvider(providerId);
  const score = computeTrustScore(stats);
  await ServiceProvider.update(
    { trust_score: score },
    { where: { id: providerId } }
  );
  return score;
}

async function maybeAutoGrantBadge(providerId) {
  if (!providerId) return;
  const provider = await ServiceProvider.findByPk(providerId);
  if (!provider) return;
  const existing = await VerificationBadge.findOne({
    where: { provider_id: providerId, badge_type: 'trusted_provider' }
  });
  if (existing && existing.status === 'approved') return;
  if (shouldGrantTrustedProvider(provider.trust_score)) {
    if (existing) {
      existing.status = 'approved';
      existing.verified_at = existing.verified_at || new Date();
      await existing.save();
    } else {
      await VerificationBadge.create({
        provider_id: providerId,
        badge_type: 'trusted_provider',
        status: 'approved',
        verified_at: new Date()
      });
    }
  }
}

module.exports = {
  computeTrustScore,
  recalculateForProvider,
  maybeAutoGrantBadge,
  shouldGrantTrustedProvider,
  WEIGHTS,
  BADGE_TYPES,
  TRUSTED_PROVIDER_THRESHOLD
};