const { sequelize } = require('../config/database');
const { Subscription, SubscriptionPlan, ServiceProvider } = require('../models');
const creditService = require('./creditService');
const { Op } = require('sequelize');

/**
 * Subscribe a provider to a plan.
 * Creates subscription, credits the provider, updates subscription_status.
 */
async function subscribe(providerId, planId) {
  const plan = await SubscriptionPlan.findByPk(planId);
  if (!plan) {
    const err = new Error('Subscription plan not found');
    err.status = 404;
    throw err;
  }
  if (!plan.is_active) {
    const err = new Error('This plan is no longer available');
    err.status = 400;
    throw err;
  }

  const provider = await ServiceProvider.findByPk(providerId);
  if (!provider) {
    const err = new Error('Provider not found');
    err.status = 404;
    throw err;
  }

  // Check for existing active subscription
  const activeSub = await Subscription.findOne({
    where: {
      provider_id: providerId,
      status: 'active',
      expires_at: { [Op.gt]: new Date() }
    }
  });
  if (activeSub) {
    const err = new Error('Provider already has an active subscription');
    err.status = 409;
    throw err;
  }

  const now = new Date();
  const expiresAt = new Date(now.getTime() + plan.duration_days * 24 * 60 * 60 * 1000);

  const subscription = await sequelize.transaction(async (t) => {
    // Create subscription record
    const sub = await Subscription.create({
      provider_id: providerId,
      plan_id: planId,
      plan_name: plan.name,
      credits: plan.credits,
      amount_paid: plan.price,
      currency: 'ETB',
      starts_at: now,
      expires_at: expiresAt,
      status: 'active'
    }, { transaction: t });

    // Credit the provider
    await creditService.creditProvider(
      providerId, plan.credits,
      `Subscription: ${plan.name}`, sub.id, 'Subscription',
      { transaction: t }
    );

    // Update provider subscription_status
    await ServiceProvider.update(
      { subscription_status: 'active' },
      { where: { id: providerId }, transaction: t }
    );

    return sub;
  });

  return Subscription.findByPk(subscription.id, {
    include: [
      { model: SubscriptionPlan, as: 'plan' }
    ]
  });
}

/**
 * Get the current active subscription for a provider.
 */
async function getActiveSubscription(providerId) {
  return Subscription.findOne({
    where: {
      provider_id: providerId,
      status: 'active',
      expires_at: { [Op.gt]: new Date() }
    },
    include: [
      { model: SubscriptionPlan, as: 'plan' }
    ]
  });
}

/**
 * Get paginated subscription history for a provider.
 */
async function getSubscriptionHistory(providerId, { page = 1, limit = 20 } = {}) {
  const offset = (page - 1) * limit;

  const { rows, count } = await Subscription.findAndCountAll({
    where: { provider_id: providerId },
    include: [
      { model: SubscriptionPlan, as: 'plan' }
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
 * Cancel a provider's subscription.
 */
async function cancelSubscription(providerId, subscriptionId) {
  const sub = await Subscription.findOne({
    where: { id: subscriptionId, provider_id: providerId }
  });

  if (!sub) {
    const err = new Error('Subscription not found');
    err.status = 404;
    throw err;
  }

  if (sub.status !== 'active') {
    const err = new Error('Subscription is not active');
    err.status = 400;
    throw err;
  }

  await sequelize.transaction(async (t) => {
    await sub.update({ status: 'cancelled' }, { transaction: t });

    // Check if provider has any other active subscription
    const otherActive = await Subscription.findOne({
      where: {
        provider_id: providerId,
        status: 'active',
        id: { [Op.ne]: subscriptionId },
        expires_at: { [Op.gt]: new Date() }
      },
      transaction: t
    });

    if (!otherActive) {
      await ServiceProvider.update(
        { subscription_status: 'inactive' },
        { where: { id: providerId }, transaction: t }
      );
    }
  });

  return sub.reload();
}

/**
 * Expire overdue subscriptions. Meant to be called by a cron/scheduler.
 */
async function checkAndExpireSubscriptions() {
  const expired = await Subscription.findAll({
    where: {
      status: 'active',
      expires_at: { [Op.lte]: new Date() }
    }
  });

  for (const sub of expired) {
    await sequelize.transaction(async (t) => {
      await sub.update({ status: 'expired' }, { transaction: t });

      // Check if provider has another active sub
      const otherActive = await Subscription.findOne({
        where: {
          provider_id: sub.provider_id,
          status: 'active',
          id: { [Op.ne]: sub.id },
          expires_at: { [Op.gt]: new Date() }
        },
        transaction: t
      });

      if (!otherActive) {
        await ServiceProvider.update(
          { subscription_status: 'expired' },
          { where: { id: sub.provider_id }, transaction: t }
        );
      }
    });
  }

  return expired.length;
}

module.exports = {
  subscribe,
  getActiveSubscription,
  getSubscriptionHistory,
  cancelSubscription,
  checkAndExpireSubscriptions
};
