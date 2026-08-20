const asyncHandler = require('../middleware/asyncHandler');
const creditService = require('../services/creditService');

/**
 * GET /api/credits/balance
 * Get the current credit balance.
 */
const getBalance = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const result = await creditService.getBalance(providerId);
  res.json({ data: result });
});

/**
 * GET /api/credits/transactions
 * Get credit transaction history.
 */
const getTransactions = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
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
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const result = await creditService.getBalanceSummary(providerId);
  res.json({ data: result });
});

module.exports = {
  getBalance,
  getTransactions,
  getSummary
};
