const { getDb } = require('../../config/database');
const categoryModel = require('./category.model');

function baseQuery() {
  return getDb()(categoryModel.tableName);
}

function ordered(query) {
  return query.orderBy([
    { column: 'sort_order', order: 'asc' },
    { column: 'name', order: 'asc' },
  ]);
}

async function create(payload) {
  const [category] = await baseQuery().insert(payload).returning('*');
  return category;
}

async function findById(id) {
  return baseQuery().where({ id }).first();
}

async function findBySlug(slug, { includeInactive = false } = {}) {
  const query = baseQuery().where({ slug });
  if (!includeInactive) {
    query.where({ is_active: true });
  }
  return query.first();
}

async function list(filters = {}) {
  const query = ordered(baseQuery());

  if (filters.status === 'active') {
    query.where({ is_active: true });
  }

  if (filters.status === 'inactive') {
    query.where({ is_active: false });
  }

  if (filters.search) {
    const keyword = '%' + filters.search + '%';
    query.andWhere((builder) => {
      builder
        .whereILike('name', keyword)
        .orWhereILike('slug', keyword)
        .orWhereILike('description', keyword);
    });
  }

  return query;
}

async function listActive() {
  return ordered(baseQuery().where({ is_active: true }));
}

async function update(id, payload) {
  const [category] = await baseQuery()
    .where({ id })
    .update({ ...payload, updated_at: getDb().fn.now() })
    .returning('*');
  return category ?? null;
}

module.exports = {
  create,
  findById,
  findBySlug,
  list,
  listActive,
  update,
};
