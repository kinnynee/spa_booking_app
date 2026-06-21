const categoryService = require('./category.service');
const { sendSuccess } = require('../../common/utils/api-response');

async function listCategories(_req, res) {
  const categories = await categoryService.listCategories();
  return sendSuccess(res, categories);
}

module.exports = {
  listCategories,
};
