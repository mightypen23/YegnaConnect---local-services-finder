const { Category } = require('../models');

async function listCategories() {
  return Category.findAll({ order: [['name', 'ASC']] });
}

module.exports = { listCategories };