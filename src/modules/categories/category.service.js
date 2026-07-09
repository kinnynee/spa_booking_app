const { AppError } = require('../../common/errors/app-error');
const cache = require('../../common/cache/cache.service');
const categoryRepository = require('./category.repository');

const CACHE_KEY = 'service-categories:active';

async function listCategories() {
  const cached = await cache.getJson(CACHE_KEY);

  if (cached) {
    return cached;
  }

  const categories = await categoryRepository.listActive();
  await cache.setJson(CACHE_KEY, categories);

  return categories;
}

async function listAdminCategories(filters = {}) {
  return categoryRepository.list(filters);
}

async function createCategory(payload) {
  const slug = toSlug(payload.slug || payload.name);
  await ensureUniqueSlug(slug);

  const category = await categoryRepository.create({
    name: payload.name,
    slug,
    description: payload.description || null,
    sort_order: payload.sortOrder ?? 0,
    is_active: payload.isActive ?? true,
  });

  await invalidateCache();
  return category;
}

async function updateCategory(id, payload) {
  const current = await categoryRepository.findById(id);
  if (!current) {
    throw new AppError('Category not found.', 404, 'CATEGORY_NOT_FOUND');
  }

  const nextPayload = {};
  if (payload.name !== undefined) {
    nextPayload.name = payload.name;
  }
  if (payload.description !== undefined) {
    nextPayload.description = payload.description || null;
  }
  if (payload.sortOrder !== undefined) {
    nextPayload.sort_order = payload.sortOrder;
  }
  if (payload.isActive !== undefined) {
    nextPayload.is_active = payload.isActive;
  }
  if (payload.slug !== undefined || payload.name !== undefined) {
    const slug = toSlug(payload.slug || payload.name || current.name);
    await ensureUniqueSlug(slug, id);
    nextPayload.slug = slug;
  }

  const category = await categoryRepository.update(id, nextPayload);
  await invalidateCache();
  return category;
}

async function archiveCategory(id) {
  const current = await categoryRepository.findById(id);
  if (!current) {
    throw new AppError('Category not found.', 404, 'CATEGORY_NOT_FOUND');
  }

  const category = await categoryRepository.update(id, { is_active: false });
  await invalidateCache();
  return category;
}

async function ensureUniqueSlug(slug, currentId = null) {
  const existing = await categoryRepository.findBySlug(slug, { includeInactive: true });
  if (existing && existing.id !== currentId) {
    throw new AppError('Category slug already exists.', 409, 'CATEGORY_SLUG_EXISTS');
  }
}

async function invalidateCache() {
  await cache.deleteKey(CACHE_KEY);
}

function toSlug(value) {
  const slug = value
    .toString()
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\u0111/g, 'd')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

  if (!slug) {
    throw new AppError('Category slug is invalid.', 400, 'CATEGORY_INVALID_SLUG');
  }

  return slug;
}

module.exports = {
  archiveCategory,
  createCategory,
  listAdminCategories,
  listCategories,
  updateCategory,
};
