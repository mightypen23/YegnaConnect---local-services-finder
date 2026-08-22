const asyncHandler = require('../middleware/asyncHandler');
const requestService = require('../services/requestService');
const ProviderRepository = require('../repositories/ProviderRepository');

const providerRepository = new ProviderRepository();

// Resolves the ServiceProvider.id for the authenticated user (credit_balance
// and requests.provider_id are keyed by this, NOT the User.id).
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
  const providerId = await resolveProviderId(req);
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
  const providerId = await resolveProviderId(req);
  const request = await requestService.acceptRequest(providerId, req.params.id);
  res.json({ data: request });
});

/**
 * PATCH /api/requests/:id/complete
 * Provider marks a request as completed.
 */
const complete = asyncHandler(async (req, res) => {
  const providerId = await resolveProviderId(req);
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
