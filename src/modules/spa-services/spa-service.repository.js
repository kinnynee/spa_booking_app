const { getDb } = require('../../config/database');
const spaServiceModel = require('./spa-service.model');

function baseQuery() {
  return getDb()(`${spaServiceModel.tableName} as services`)
    .join('service_categories as categories', 'categories.id', 'services.category_id')
    .where('services.is_active', true)
    .where('categories.is_active', true)
    .select(
      'services.*',
      'categories.id as category_id',
      'categories.name as category_name',
      'categories.slug as category_slug',
    );
}

async function list(filters = {}) {
  const query = baseQuery().orderBy([
    { column: 'services.is_popular', order: 'desc' },
    { column: 'services.name', order: 'asc' },
  ]);

  if (filters.categorySlug) {
    query.where('categories.slug', filters.categorySlug);
  }

  if (filters.search) {
    const keyword = `%${filters.search}%`;
    query.andWhere((builder) => {
      builder
        .whereILike('services.name', keyword)
        .orWhereILike('services.slug', keyword)
        .orWhereILike('services.description', keyword)
        .orWhereILike('categories.name', keyword)
        .orWhereILike('categories.slug', keyword);
    });
  }

  return query;
}

async function findById(id) {
  return baseQuery().where('services.id', id).first();
}

async function findBySlug(slug) {
  return baseQuery().where('services.slug', slug).first();
}

module.exports = {
  findById,
  findBySlug,
  list,
};
