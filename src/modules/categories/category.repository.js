const { getDb } = require('../../config/database');
const categoryModel = require('./category.model');

async function listActive() {
  return getDb()(categoryModel.tableName)
    .where({ is_active: true })
    .orderBy([
      { column: 'sort_order', order: 'asc' },
      { column: 'name', order: 'asc' },
    ]);
}

async function findBySlug(slug) {
  return getDb()(categoryModel.tableName).where({ slug, is_active: true }).first();
}

module.exports = {
  findBySlug,
  listActive,
};
