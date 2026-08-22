const { Category } = require('../models');
const { Op } = require('sequelize');

async function listCategories() {
  return Category.findAll({
    where: { name: { [Op.notLike]: 'Verification Plumbing %' } },
    order: [['name', 'ASC']]
  });
}

module.exports = { listCategories };
