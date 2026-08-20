const { Op } = require('sequelize');

/**
 * BaseRepository — abstract data-access class with common CRUD patterns.
 * Subclass and set `this.model` in the constructor to use.
 */
class BaseRepository {
  constructor(model) {
    this.model = model;
  }

  async findById(id, options = {}) {
    return this.model.findByPk(id, options);
  }

  async findOne(where, options = {}) {
    return this.model.findOne({ where, ...options });
  }

  async findAll(where = {}, options = {}) {
    return this.model.findAll({ where, ...options });
  }

  async create(data, options = {}) {
    return this.model.create(data, options);
  }

  async update(id, data, options = {}) {
    const instance = await this.model.findByPk(id);
    if (!instance) return null;
    return instance.update(data, options);
  }

  async delete(id, options = {}) {
    const instance = await this.model.findByPk(id);
    if (!instance) return null;
    await instance.destroy(options);
    return instance;
  }

  /**
   * Paginated query helper.
   *
   * @param {object} where    Sequelize where clause
   * @param {object} opts     Extra query options (include, order, etc.)
   * @param {number} page     1-indexed page number
   * @param {number} limit    Items per page
   * @returns {{ rows, count, page, limit, totalPages }}
   */
  async paginate(where = {}, opts = {}, page = 1, limit = 20) {
    const offset = (page - 1) * limit;

    const { rows, count } = await this.model.findAndCountAll({
      where,
      offset,
      limit,
      ...opts
    });

    return {
      rows,
      count,
      page,
      limit,
      totalPages: Math.ceil(count / limit)
    };
  }
}

module.exports = BaseRepository;
