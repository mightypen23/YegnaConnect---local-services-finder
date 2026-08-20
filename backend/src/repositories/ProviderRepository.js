const { ServiceProvider, ProviderCategory, ProviderLocation } = require('../models');

function dedupeCategories(categories = []) {
  const byId = new Map();
  for (const c of categories) {
    byId.set(c.id, c);
  }
  return [...byId.values()];
}

class ProviderRepository {
  async createProvider({ id, user_id, bio }, options = {}) {
    return ServiceProvider.create(
      { ...(id ? { id } : {}), user_id, bio },
      options
    );
  }

  async addCategories(providerId, categories = [], options = {}) {
    return this._createCategoryLinks(providerId, dedupeCategories(categories), options);
  }

  async _createCategoryLinks(providerId, uniqueCategories, options) {
    if (!uniqueCategories || uniqueCategories.length === 0) {
      return [];
    }
    return ProviderCategory.bulkCreate(
      uniqueCategories.map((c) => ({
        provider_id: providerId,
        category_id: c.id,
        skill_level: c.skill_level || 'intermediate'
      })),
      options
    );
  }

  async findByUserId(userId, options = {}) {
    return ServiceProvider.findOne({ where: { user_id: userId }, ...options });
  }

  async findById(id, options = {}) {
    return ServiceProvider.findByPk(id, options);
  }

  async findAll(options = {}) {
    return ServiceProvider.findAll(options);
  }

  async replaceCategories(providerId, categories = [], options = {}) {
    await ProviderCategory.destroy({ where: { provider_id: providerId }, ...options });
    return this._createCategoryLinks(providerId, dedupeCategories(categories), options);
  }

  async updateLocation(providerId, location, options = {}) {
    await ProviderLocation.destroy({ where: { provider_id: providerId }, ...options });
    return ProviderLocation.create({ provider_id: providerId, ...location }, options);
  }

  async findLatestLocation(providerId, options = {}) {
    return ProviderLocation.findOne({
      where: { provider_id: providerId },
      order: [['created_at', 'DESC']],
      ...options
    });
  }
}

module.exports = ProviderRepository;