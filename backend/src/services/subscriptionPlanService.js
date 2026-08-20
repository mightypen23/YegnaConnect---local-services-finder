const { SubscriptionPlan } = require('../models');

/**
 * Get all subscription plans, optionally including inactive ones.
 */
async function getAllPlans(includeInactive = false) {
  const where = includeInactive ? {} : { is_active: true };
  return SubscriptionPlan.findAll({
    where,
    order: [['price', 'ASC']]
  });
}

/**
 * Get a single plan by ID.
 */
async function getPlanById(planId) {
  const plan = await SubscriptionPlan.findByPk(planId);
  if (!plan) {
    const err = new Error('Subscription plan not found');
    err.status = 404;
    throw err;
  }
  return plan;
}

/**
 * Create a new subscription plan (admin only).
 */
async function createPlan(data) {
  const { name, price, credits, duration_days, features, is_active } = data;

  // Check for duplicate name
  const existing = await SubscriptionPlan.findOne({ where: { name } });
  if (existing) {
    const err = new Error('A plan with this name already exists');
    err.status = 409;
    throw err;
  }

  return SubscriptionPlan.create({
    name,
    price,
    credits,
    duration_days,
    features: features || {},
    is_active: is_active !== undefined ? is_active : true
  });
}

/**
 * Update an existing plan (admin only).
 */
async function updatePlan(planId, data) {
  const plan = await SubscriptionPlan.findByPk(planId);
  if (!plan) {
    const err = new Error('Subscription plan not found');
    err.status = 404;
    throw err;
  }

  const allowedFields = ['name', 'price', 'credits', 'duration_days', 'features', 'is_active'];
  const updates = {};
  allowedFields.forEach((field) => {
    if (data[field] !== undefined) updates[field] = data[field];
  });

  return plan.update(updates);
}

/**
 * Soft-deactivate a plan (admin only).
 */
async function deactivatePlan(planId) {
  const plan = await SubscriptionPlan.findByPk(planId);
  if (!plan) {
    const err = new Error('Subscription plan not found');
    err.status = 404;
    throw err;
  }

  return plan.update({ is_active: false });
}

module.exports = {
  getAllPlans,
  getPlanById,
  createPlan,
  updatePlan,
  deactivatePlan
};
