const asyncHandler = require('../middleware/asyncHandler');
const subscriptionService = require('../services/subscriptionService');

/**
 * POST /api/subscriptions
 * Subscribe to a plan.
 */
const subscribe = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const subscription = await subscriptionService.subscribe(providerId, req.body.plan_id);
  res.status(201).json({ data: subscription });
});

/**
 * GET /api/subscriptions/active
 * Get the current active subscription.
 */
const getActive = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const subscription = await subscriptionService.getActiveSubscription(providerId);
  if (!subscription) {
    return res.json({ data: null, message: 'No active subscription' });
  }
  res.json({ data: subscription });
});

/**
 * GET /api/subscriptions/history
 * Get subscription history.
 */
const getHistory = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const { page, limit } = req.query;
  const result = await subscriptionService.getSubscriptionHistory(providerId, {
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

/**
 * PATCH /api/subscriptions/:id/cancel
 * Cancel a subscription.
 */
const cancel = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const subscription = await subscriptionService.cancelSubscription(providerId, req.params.id);
  res.json({ data: subscription, message: 'Subscription cancelled' });
});

module.exports = {
  subscribe,
  getActive,
  getHistory,
  cancel
};
