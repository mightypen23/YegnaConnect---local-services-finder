const BaseRepository = require('./BaseRepository');
const { ServiceRequest, User, ServiceProvider, Category } = require('../models');
const { Op } = require('sequelize');

const DEFAULT_INCLUDES = [
  { model: User, as: 'customer', attributes: ['id', 'full_name', 'phone_number', 'email'] },
  {
    model: ServiceProvider,
    as: 'provider',
    attributes: ['id', 'user_id', 'bio', 'trust_score', 'availability_status'],
    include: [{ model: User, as: 'user', attributes: ['id', 'full_name', 'phone_number'] }]
  },
  { model: Category, as: 'category', attributes: ['id', 'name', 'name_amharic', 'icon'] }
];

class RequestRepository extends BaseRepository {
  constructor() {
    super(ServiceRequest);
  }

  /**
   * Find a request by ID with eager-loaded associations.
   */
  async findById(id, options = {}) {
    return this.model.findByPk(id, {
      include: DEFAULT_INCLUDES,
      ...options
    });
  }

  /**
   * Paginated requests for a customer.
   */
  async findByCustomer(customerId, { status, page = 1, limit = 20 } = {}) {
    const where = { customer_id: customerId };
    if (status) where.status = status;

    return this.paginate(where, {
      include: DEFAULT_INCLUDES,
      order: [['created_at', 'DESC']]
    }, page, limit);
  }

  /**
   * Paginated requests for a provider.
   */
  async findByProvider(providerId, { status, page = 1, limit = 20 } = {}) {
    const where = { provider_id: providerId };
    if (status) where.status = status;

    return this.paginate(where, {
      include: DEFAULT_INCLUDES,
      order: [['created_at', 'DESC']]
    }, page, limit);
  }

  /**
   * Find pending requests in a specific category (for lead matching).
   */
  async findPendingByCategory(categoryId, { page = 1, limit = 20 } = {}) {
    const where = {
      category_id: categoryId,
      status: 'pending',
      provider_id: null
    };

    return this.paginate(where, {
      include: DEFAULT_INCLUDES,
      order: [['created_at', 'ASC']]
    }, page, limit);
  }

  /**
   * Update request status. Returns updated instance or null if not found.
   */
  async updateStatus(id, status, options = {}) {
    const request = await this.model.findByPk(id);
    if (!request) return null;
    return request.update({ status }, options);
  }

  /**
   * Count requests grouped by status for a provider.
   */
  async countByStatus(providerId) {
    const results = await this.model.findAll({
      attributes: [
        'status',
        [this.model.sequelize.fn('COUNT', this.model.sequelize.col('id')), 'count']
      ],
      where: { provider_id: providerId },
      group: ['status'],
      raw: true
    });

    const counts = {};
    results.forEach(r => { counts[r.status] = parseInt(r.count, 10); });
    return counts;
  }
}

module.exports = new RequestRepository();
