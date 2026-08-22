const { sequelize } = require('../config/database');
const { Review, ServiceRequest, ServiceProvider, User } = require('../models');

/**
 * Create a review for a completed service request.
 */
async function createReview(customerId, data) {
  const { provider_id, request_id, rating, comment } = data;

  // Verify provider exists
  const provider = await ServiceProvider.findByPk(provider_id);
  if (!provider) {
    const err = new Error('Provider not found');
    err.status = 404;
    throw err;
  }

  // If request_id given, verify the request is completed and belongs to customer
  if (request_id) {
    const request = await ServiceRequest.findByPk(request_id);
    if (!request) {
      const err = new Error('Service request not found');
      err.status = 404;
      throw err;
    }
    if (request.customer_id !== customerId) {
      const err = new Error('You can only review your own service requests');
      err.status = 403;
      throw err;
    }
    if (request.status !== 'completed') {
      const err = new Error('Can only review completed requests');
      err.status = 400;
      throw err;
    }
  }

  // Check for duplicate review
  const existing = await Review.findOne({
    where: {
      provider_id,
      customer_id: customerId,
      ...(request_id ? { request_id } : {})
    }
  });
  if (existing) {
    const err = new Error('You have already reviewed this provider for this request');
    err.status = 409;
    throw err;
  }

  // Create the review and update provider trust_score in a transaction
  const review = await sequelize.transaction(async (t) => {
    const newReview = await Review.create({
      provider_id,
      customer_id: customerId,
      request_id: request_id || null,
      rating,
      comment
    }, { transaction: t });

    // Recalculate provider trust_score
    await recalculateTrustScore(provider_id, t);

    return newReview;
  });

  return Review.findByPk(review.id, {
    include: [
      { model: User, as: 'customer', attributes: ['id', 'full_name'] }
    ]
  });
}

/**
 * Get paginated reviews for a provider.
 */
async function getReviewsForProvider(providerId, { page = 1, limit = 20 } = {}) {
  const offset = (page - 1) * limit;

  const { rows, count } = await Review.findAndCountAll({
    where: { provider_id: providerId },
    include: [
      { model: User, as: 'customer', attributes: ['id', 'full_name'] }
    ],
    order: [['created_at', 'DESC']],
    offset,
    limit
  });

  return {
    rows,
    count,
    page,
    limit,
    totalPages: Math.ceil(count / limit)
  };
}

/**
 * Get review for a specific request.
 */
async function getReviewByRequestId(requestId) {
  return Review.findOne({
    where: { request_id: requestId },
    include: [
      { model: User, as: 'customer', attributes: ['id', 'full_name'] }
    ]
  });
}

/**
 * Get rating statistics for a provider.
 */
async function getProviderStats(providerId) {
  const reviews = await Review.findAll({
    where: { provider_id: providerId },
    attributes: ['rating'],
    raw: true
  });

  if (reviews.length === 0) {
    return {
      averageRating: 0,
      totalReviews: 0,
      distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
    };
  }

  const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  let total = 0;
  reviews.forEach((r) => {
    distribution[r.rating] = (distribution[r.rating] || 0) + 1;
    total += r.rating;
  });

  return {
    averageRating: parseFloat((total / reviews.length).toFixed(2)),
    totalReviews: reviews.length,
    distribution
  };
}

/**
 * Recalculate and persist provider trust_score as the average rating.
 */
async function recalculateTrustScore(providerId, transaction) {
  const [result] = await sequelize.query(
    `SELECT COALESCE(AVG(rating), 0) AS avg_rating FROM reviews WHERE provider_id = :providerId`,
    {
      replacements: { providerId },
      type: sequelize.QueryTypes.SELECT,
      transaction
    }
  );

  await ServiceProvider.update(
    { trust_score: parseFloat(Number(result.avg_rating).toFixed(2)) },
    { where: { id: providerId }, transaction }
  );
}

module.exports = {
  createReview,
  getReviewsForProvider,
  getReviewByRequestId,
  getProviderStats
};
