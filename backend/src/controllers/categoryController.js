const { listCategories } = require('../services/categoryService');

const list = async (req, res, next) => {
  try {
    const categories = await listCategories();
    res.json({ categories });
  } catch (err) {
    next(err);
  }
};

module.exports = { list };