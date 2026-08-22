const asyncHandler = require('../middleware/asyncHandler');
const reviewService = require('../services/reviewService');

/**
 * POST /api/reviews
 * Submit a review for a provider.
 */
const create = asyncHandler(async (req, res) => {
  const review = await reviewService.createReview(req.user.id, req.body);
  res.status(201).json({ data: review });
});

/**
 * GET /api/reviews/provider/:providerId
 * List reviews for a provider.
 */
const getForProvider = asyncHandler(async (req, res) => {
  const { page, limit } = req.query;
  const result = await reviewService.getReviewsForProvider(req.params.providerId, {
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

/**
 * GET /api/reviews/request/:requestId
 * Get review for a specific service request.
 */
const getByRequest = asyncHandler(async (req, res) => {
  const review = await reviewService.getReviewByRequestId(req.params.requestId);
  if (!review) {
    return res.status(404).json({ error: 'No review found for this request' });
  }
  res.json({ data: review });
});

/**
 * GET /api/reviews/provider/:providerId/stats
 * Get rating statistics for a provider.
 */
const getProviderStats = asyncHandler(async (req, res) => {
  const stats = await reviewService.getProviderStats(req.params.providerId);
  res.json({ data: stats });
});

module.exports = {
  create,
  getForProvider,
  getByRequest,
  getProviderStats
};
