const { getDb } = require('../../config/database');
const spaServiceModel = require('./spa-service.model');

function baseQuery({ includeInactive = false } = {}) {
  const query = getDb()(`${spaServiceModel.tableName} as services`)
    .join('service_categories as categories', 'categories.id', 'services.category_id')
    .select(
      'services.*',
      'categories.id as category_id',
      'categories.name as category_name',
      'categories.slug as category_slug',
    );

  if (!includeInactive) {
    query.where('services.is_active', true).where('categories.is_active', true);
  }

  return query;
}

async function list(filters = {}, { includeInactive = false } = {}) {
  const query = baseQuery({ includeInactive }).orderBy([
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

  if (filters.minPrice !== undefined) {
    query.where('services.price', '>=', filters.minPrice);
  }

  if (filters.maxPrice !== undefined) {
    query.where('services.price', '<=', filters.maxPrice);
  }

  if (filters.status === 'active') {
    query.where('services.is_active', true);
  }
  if (filters.status === 'inactive') {
    query.where('services.is_active', false);
  }

  return query;
}

async function findById(id) {
  return baseQuery().where('services.id', id).first();
}

async function findByIdForAdmin(id) {
  return baseQuery({ includeInactive: true }).where('services.id', id).first();
}

async function findBySlug(slug, { includeInactive = false } = {}) {
  return baseQuery({ includeInactive }).where('services.slug', slug).first();
}

async function create(payload) {
  const [service] = await getDb()(spaServiceModel.tableName).insert(payload).returning('*');
  return findByIdForAdmin(service.id);
}

async function update(id, payload) {
  await getDb()(spaServiceModel.tableName)
    .where({ id })
    .update({ ...payload, updated_at: getDb().fn.now() });
  return findByIdForAdmin(id);
}

module.exports = {
  create,
  findById,
  findByIdForAdmin,
  findBySlug,
  list,
  update,
};
