const asyncHandler = require('../middleware/asyncHandler');
const subscriptionPlanService = require('../services/subscriptionPlanService');

/**
 * GET /api/plans
 * List all active subscription plans (public).
 */
const getAll = asyncHandler(async (req, res) => {
  const includeInactive = req.query.include_inactive === 'true' && req.user && req.user.role === 'admin';
  const plans = await subscriptionPlanService.getAllPlans(includeInactive);
  res.json({ data: plans });
});

/**
 * GET /api/plans/:id
 * Get a single subscription plan.
 */
const getById = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.getPlanById(req.params.id);
  res.json({ data: plan });
});

/**
 * POST /api/plans
 * Create a new subscription plan (admin only).
 */
const create = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.createPlan(req.body);
  res.status(201).json({ data: plan });
});

/**
 * PUT /api/plans/:id
 * Update a subscription plan (admin only).
 */
const update = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.updatePlan(req.params.id, req.body);
  res.json({ data: plan });
});

/**
 * DELETE /api/plans/:id
 * Deactivate a subscription plan (admin only).
 */
const deactivate = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.deactivatePlan(req.params.id);
  res.json({ data: plan, message: 'Plan deactivated' });
});

module.exports = {
  getAll,
  getById,
  create,
  update,
  deactivate
};
