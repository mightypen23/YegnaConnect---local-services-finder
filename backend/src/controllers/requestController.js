const asyncHandler = require('../middleware/asyncHandler');
const requestService = require('../services/requestService');

/**
 * POST /api/requests
 * Create a new service request.
 */
const create = asyncHandler(async (req, res) => {
  const request = await requestService.createRequest(req.user.id, req.body);
  res.status(201).json({ data: request });
});

/**
 * GET /api/requests/me
 * Get current customer's requests.
 */
const getMyRequests = asyncHandler(async (req, res) => {
  const { status, page, limit } = req.query;
  const result = await requestService.getRequestsForCustomer(req.user.id, {
    status,
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

/**
 * GET /api/requests/provider
 * Get requests assigned to the current provider.
 */
const getProviderRequests = asyncHandler(async (req, res) => {
  const { status, page, limit } = req.query;
  // The provider record ID should come from the provider profile linked to req.user.id.
  // For simplicity we accept provider_id from a header or resolve from user.
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const result = await requestService.getRequestsForProvider(providerId, {
    status,
    page: parseInt(page, 10) || 1,
    limit: parseInt(limit, 10) || 20
  });
  res.json({ data: result.rows, meta: { count: result.count, page: result.page, limit: result.limit, totalPages: result.totalPages } });
});

/**
 * GET /api/requests/:id
 * Get a single request by ID.
 */
const getById = asyncHandler(async (req, res) => {
  const request = await requestService.getRequestById(req.params.id, req.user.id);
  res.json({ data: request });
});

/**
 * PATCH /api/requests/:id/accept
 * Provider accepts a request.
 */
const accept = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const request = await requestService.acceptRequest(providerId, req.params.id);
  res.json({ data: request });
});

/**
 * PATCH /api/requests/:id/complete
 * Provider marks a request as completed.
 */
const complete = asyncHandler(async (req, res) => {
  const providerId = req.headers['x-provider-id'] || req.user.id;
  const request = await requestService.completeRequest(providerId, req.params.id);
  res.json({ data: request });
});

/**
 * PATCH /api/requests/:id/cancel
 * Cancel a request.
 */
const cancel = asyncHandler(async (req, res) => {
  const request = await requestService.cancelRequest(req.user.id, req.params.id, req.body.reason);
  res.json({ data: request });
});

module.exports = {
  create,
  getMyRequests,
  getProviderRequests,
  getById,
  accept,
  complete,
  cancel
};
