const { CreditTransaction, ServiceProvider } = require('../models');
const { sequelize } = require('../config/database');

/**
 * Get the current credit balance for a provider.
 */
async function getBalance(providerId) {
  const provider = await ServiceProvider.findByPk(providerId, {
    attributes: ['id', 'credit_balance']
  });

  if (!provider) {
    const err = new Error('Provider not found');
    err.status = 404;
    throw err;
  }

  return { providerId, balance: provider.credit_balance };
}

/**
 * Get paginated credit transaction history for a provider.
 */
async function getTransactionHistory(providerId, { type, page = 1, limit = 20 } = {}) {
  const offset = (page - 1) * limit;
  const where = { provider_id: providerId };
  if (type) where.type = type;

  const { rows, count } = await CreditTransaction.findAndCountAll({
    where,
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
 * Credit (add) credits to a provider account.
 *
 * @param {string} providerId
 * @param {number} amount        Positive integer
 * @param {string} reason        Human-readable reason
 * @param {string} referenceId   Optional FK to related entity
 * @param {string} referenceType Optional entity type (e.g. 'Subscription')
 * @param {object} options       { transaction }
 */
async function creditProvider(providerId, amount, reason, referenceId, referenceType, options = {}) {
  if (amount <= 0) {
    const err = new Error('Credit amount must be positive');
    err.status = 400;
    throw err;
  }

  const transaction = await CreditTransaction.create({
    provider_id: providerId,
    amount,
    type: 'credit',
    reason,
    reference_id: referenceId || null,
    reference_type: referenceType || null
  }, options);
  return transaction;
}

/**
 * Debit (deduct) credits from a provider account.
 * Throws if insufficient balance.
 */
async function debitProvider(providerId, amount, reason, referenceId, referenceType, options = {}) {
  if (amount <= 0) {
    const err = new Error('Debit amount must be positive');
    err.status = 400;
    throw err;
  }

  // Check balance
  const provider = await ServiceProvider.findByPk(providerId, {
    attributes: ['id', 'credit_balance'],
    ...(options.transaction ? { transaction: options.transaction } : {})
  });

  if (!provider) {
    const err = new Error('Provider not found');
    err.status = 404;
    throw err;
  }

  if (provider.credit_balance < amount) {
    const err = new Error('Insufficient credit balance');
    err.status = 402;
    throw err;
  }

  return CreditTransaction.create({
    provider_id: providerId,
    amount,
    type: 'debit',
    reason,
    reference_id: referenceId || null,
    reference_type: referenceType || null
  }, options);
}

/**
 * Get credit balance summary: total credited, total debited, current balance.
 */
async function getBalanceSummary(providerId) {
  const provider = await ServiceProvider.findByPk(providerId, {
    attributes: ['id', 'credit_balance']
  });

  if (!provider) {
    const err = new Error('Provider not found');
    err.status = 404;
    throw err;
  }

  const [result] = await sequelize.query(
    `SELECT
       COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) AS total_credited,
       COALESCE(SUM(CASE WHEN type = 'debit'  THEN amount ELSE 0 END), 0) AS total_debited
     FROM credit_transactions
     WHERE provider_id = :providerId`,
    {
      replacements: { providerId },
      type: sequelize.QueryTypes.SELECT
    }
  );

  return {
    providerId,
    balance: provider.credit_balance,
    totalCredited: parseInt(result.total_credited, 10),
    totalDebited: parseInt(result.total_debited, 10)
  };
}

module.exports = {
  getBalance,
  getTransactionHistory,
  creditProvider,
  debitProvider,
  getBalanceSummary
};
