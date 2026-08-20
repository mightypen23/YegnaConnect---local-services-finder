const { sequelize } = require('../config/database');
const { ServiceRequest, ServiceProvider, Category, User } = require('../models');
const requestRepository = require('../repositories/RequestRepository');
const creditService = require('./creditService');

const LEAD_COST = 1; // Credits deducted when a provider accepts a request

/**
 * Create a new service request from a customer.
 */
async function createRequest(customerId, data) {
  const { category_id, description, latitude, longitude, provider_id, client_id } = data;

  // Verify category exists
  const category = await Category.findByPk(category_id);
  if (!category) {
    const err = new Error('Category not found');
    err.status = 404;
    throw err;
  }

  // Optionally verify target provider exists
  if (provider_id) {
    const provider = await ServiceProvider.findByPk(provider_id);
    if (!provider) {
      const err = new Error('Provider not found');
      err.status = 404;
      throw err;
    } ewe
  }

  const request = await requestRepository.create({
    customer_id: customerId,
    category_id,
    provider_id: provider_id || null,
    description,
    latitude,
    longitude,
    client_id: client_id || null,
    status: 'pending'
  });

  return requestRepository.findById(request.id);
}

/**
 * Provider accepts a pending request.
 * Deducts a lead credit from the provider.
 */
async function acceptRequest(providerId, requestId) {
  const request = await requestRepository.findById(requestId);
  if (!request) {
    const err = new Error('Request not found');
    err.status = 404;
    throw err;
  }

  if (request.status !== 'pending') {
    const err = new Error(`Cannot accept a request with status "${request.status}"`);
    err.status = 400;
    throw err;
  }

  // Use a transaction for atomicity: debit credit + update request
  const result = await sequelize.transaction(async (t) => {
    // Deduct lead credit
    await creditService.debitProvider(
      providerId, LEAD_COST,
      'Lead accepted', requestId, 'ServiceRequest',
      { transaction: t }
    );

    // Update request
    await request.update({
      provider_id: providerId,
      status: 'accepted'
    }, { transaction: t });

    return request;
  });

  return requestRepository.findById(result.id);
}

/**
 * Provider marks request as completed.
 */
async function completeRequest(providerId, requestId) {
  const request = await requestRepository.findById(requestId);
  if (!request) {
    const err = new Error('Request not found');
    err.status = 404;
    throw err;
  }

  if (request.provider_id !== providerId) {
    const err = new Error('Not authorized to complete this request');
    err.status = 403;
    throw err;
  }

  if (!['accepted', 'in_progress'].includes(request.status)) {
    const err = new Error(`Cannot complete a request with status "${request.status}"`);
    err.status = 400;
    throw err;
  }

  await request.update({ status: 'completed' });
  return requestRepository.findById(request.id);
}

/**
 * Cancel a request. Customer or provider can cancel.
 * If provider had accepted, refund the lead credit.
 */
async function cancelRequest(userId, requestId, reason) {
  const request = await requestRepository.findById(requestId);
  if (!request) {
    const err = new Error('Request not found');
    err.status = 404;
    throw err;
  }

  // Only customer or assigned provider may cancel
  if (request.customer_id !== userId && request.provider_id !== userId) {
    const err = new Error('Not authorized to cancel this request');
    err.status = 403;
    throw err;
  }

  if (['completed', 'cancelled', 'failed'].includes(request.status)) {
    const err = new Error(`Cannot cancel a request with status "${request.status}"`);
    err.status = 400;
    throw err;
  }

  await sequelize.transaction(async (t) => {
    // Refund credit if provider had accepted
    if (request.provider_id && request.status === 'accepted') {
      await creditService.creditProvider(
        request.provider_id, LEAD_COST,
        'Lead cancelled — refund', requestId, 'ServiceRequest',
        { transaction: t }
      );
    }

    await request.update({ status: 'cancelled' }, { transaction: t });
  });

  return requestRepository.findById(request.id);
}

/**
 * Get paginated requests for a customer.
 */
async function getRequestsForCustomer(customerId, filters = {}) {
  return requestRepository.findByCustomer(customerId, filters);
}

/**
 * Get paginated requests for a provider.
 */
async function getRequestsForProvider(providerId, filters = {}) {
  return requestRepository.findByProvider(providerId, filters);
}

/**
 * Get a single request by ID with access control.
 */
async function getRequestById(requestId, userId) {
  const request = await requestRepository.findById(requestId);
  if (!request) {
    const err = new Error('Request not found');
    err.status = 404;
    throw err;
  }

  return request;
}

module.exports = {
  createRequest,
  acceptRequest,
  completeRequest,
  cancelRequest,
  getRequestsForCustomer,
  getRequestsForProvider,
  getRequestById
};
