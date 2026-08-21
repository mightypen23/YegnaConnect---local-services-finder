const asyncHandler = require('../middleware/asyncHandler');
const creditService = require('../services/creditService');
const ProviderRepository = require('../repositories/ProviderRepository');

const providerRepository = new ProviderRepository();

// Resolves the ServiceProvider.id for the authenticated user (credit_balance
// is keyed by this, NOT the User.id).
async function resolveProviderId(req) {
  if (req.headers['x-provider-id']) return req.headers['x-provider-id'];
  const provider = await providerRepository.findByUserId(req.user.id);
  if (!provider) {
    const err = new Error('Provider profile not found for this account');
    err.status = 404;
    throw err;
  }
  return provider.id;
}

function sanitizeCreditTransaction(tx) {
  if (!tx) return null;
  const t = tx.toJSON ? tx.toJSON() : tx;
  return {
    id: t.id,
    provider_id: t.provider_id,
    amount: t.amount,
    type: t.type,
    reason: t.reason,
    reference_id: t.reference_id,
    reference_type: t.reference_type,
    created_at: t.created_at
  };
}

/**
 * GET /api/credits/balance
 * Get the current credit balance.
 */
const getBalance = asyncHandler(async (req, res) => {
  const providerId = await resolveProviderId(req);
  const result = await creditService.getBalance(providerId);
  res.json({ data: result });
});

/**
 * GET /api/credits/transactions
 * Get credit transaction history.
 */
const getTransactions = asyncHandler(async (req, res) => {
  const providerId = await resolveProviderId(req);
  const { type, page, limit } = req.query;
  const result = await creditService.getTransactionHistory(providerId, {
    type,
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

/**
 * GET /api/credits/summary
 * Get credit balance summary (total credited, total debited, balance).
 */
const getSummary = asyncHandler(async (req, res) => {
  const providerId = await resolveProviderId(req);
  const result = await creditService.getBalanceSummary(providerId);
  res.json({ data: result });
});

/**
 * POST /api/credits/purchase
 * Buy credit top-up packages (50 birr = 100 credits each).
 */
const purchaseCredits = asyncHandler(async (req, res) => {
  const providerId = await resolveProviderId(req);
  const packages = parseInt(req.body.packages, 10) || 1;
  const result = await creditService.purchaseCredits(providerId, packages);
  res.status(201).json({ data: result });
});

module.exports = {
  getBalance,
  getTransactions,
  getSummary,
  purchaseCredits,
  sanitizeCreditTransaction
};
