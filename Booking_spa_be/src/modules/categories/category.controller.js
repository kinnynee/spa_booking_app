const categoryService = require('./category.service');
const { sendCreated, sendSuccess } = require('../../common/utils/api-response');

async function listCategories(_req, res) {
  const categories = await categoryService.listCategories();
  return sendSuccess(res, categories);
}

async function listAdminCategories(req, res) {
  const categories = await categoryService.listAdminCategories(req.validated.query);
  return sendSuccess(res, categories);
}

async function createCategory(req, res) {
  const category = await categoryService.createCategory(req.validated.body);
  return sendCreated(res, category, 'Category created.');
}

async function updateCategory(req, res) {
  const category = await categoryService.updateCategory(
    req.validated.params.id,
    req.validated.body,
  );
  return sendSuccess(res, category, 'Category updated.');
}

async function archiveCategory(req, res) {
  const category = await categoryService.archiveCategory(req.validated.params.id);
  return sendSuccess(res, category, 'Category archived.');
}

module.exports = {
  archiveCategory,
  createCategory,
  listAdminCategories,
  listCategories,
  updateCategory,
};
