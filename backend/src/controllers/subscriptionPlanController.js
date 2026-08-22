const asyncHandler = require('../middleware/asyncHandler');
const subscriptionPlanService = require('../services/subscriptionPlanService');

const getAll = asyncHandler(async (req, res) => {
  const includeInactive = req.query.include_inactive === 'true' && req.user?.role === 'admin';
  const plans = await subscriptionPlanService.getAllPlans(includeInactive);
  res.json({ data: plans, plans });
});

const getById = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.getPlanById(req.params.id);
  res.json({ data: plan, plan });
});

const create = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.createPlan(req.body);
  res.status(201).json({ data: plan, plan });
});

const update = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.updatePlan(req.params.id, req.body);
  res.json({ data: plan, plan });
});

const deactivate = asyncHandler(async (req, res) => {
  const plan = await subscriptionPlanService.deactivatePlan(req.params.id);
  res.json({ data: plan, plan, message: 'Plan deactivated' });
});

module.exports = {
  getAll,
  getById,
  create,
  update,
  deactivate,
  listPublic: getAll,
  listAdmin: getAll,
  createValidators: [],
  updateValidators: [],
  sanitizePlan: (plan) => (plan?.toJSON ? plan.toJSON() : plan)
};
