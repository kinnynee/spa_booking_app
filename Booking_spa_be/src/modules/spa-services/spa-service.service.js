const { AppError } = require('../../common/errors/app-error');
const categoryRepository = require('../categories/category.repository');
const spaServiceRepository = require('./spa-service.repository');
const { toSpaServiceDto } = require('./spa-service.dto');

async function listSpaServices(filters) {
  const services = await spaServiceRepository.list(filters);
  return services.map(toSpaServiceDto);
}

async function listAdminSpaServices(filters) {
  const services = await spaServiceRepository.list(filters, { includeInactive: true });
  return services.map(toSpaServiceDto);
}

async function getSpaService(id) {
  const service = await spaServiceRepository.findById(id);

  if (!service) {
    throw new AppError('Service not found.', 404, 'SERVICE_NOT_FOUND');
  }

  return toSpaServiceDto(service);
}

async function createSpaService(payload) {
  await ensureCategory(payload.categoryId);
  const slug = toSlug(payload.slug || payload.name);
  await ensureUniqueSlug(slug);
  const service = await spaServiceRepository.create({
    category_id: payload.categoryId,
    name: payload.name,
    slug,
    description: payload.description || null,
    price: payload.price,
    duration_minutes: payload.durationMinutes,
    image_url: payload.imageUrl || null,
    is_popular: payload.isPopular ?? false,
    is_active: payload.isActive ?? true,
  });
  return toSpaServiceDto(service);
}

async function updateSpaService(id, payload) {
  const current = await spaServiceRepository.findByIdForAdmin(id);
  if (!current) {
    throw new AppError('Service not found.', 404, 'SERVICE_NOT_FOUND');
  }

  if (payload.categoryId !== undefined) {
    await ensureCategory(payload.categoryId);
  }

  const nextPayload = {};
  const fields = {
    categoryId: 'category_id',
    name: 'name',
    description: 'description',
    price: 'price',
    durationMinutes: 'duration_minutes',
    imageUrl: 'image_url',
    isPopular: 'is_popular',
    isActive: 'is_active',
  };
  for (const [inputKey, column] of Object.entries(fields)) {
    if (payload[inputKey] !== undefined) {
      nextPayload[column] = payload[inputKey];
    }
  }

  if (payload.slug !== undefined || payload.name !== undefined) {
    const slug = toSlug(payload.slug || payload.name || current.name);
    await ensureUniqueSlug(slug, id);
    nextPayload.slug = slug;
  }

  const service = await spaServiceRepository.update(id, nextPayload);
  return toSpaServiceDto(service);
}

async function archiveSpaService(id) {
  const current = await spaServiceRepository.findByIdForAdmin(id);
  if (!current) {
    throw new AppError('Service not found.', 404, 'SERVICE_NOT_FOUND');
  }
  const service = await spaServiceRepository.update(id, { is_active: false });
  return toSpaServiceDto(service);
}

async function ensureCategory(categoryId) {
  const category = await categoryRepository.findById(categoryId);
  if (!category) {
    throw new AppError('Category not found.', 404, 'CATEGORY_NOT_FOUND');
  }
}

async function ensureUniqueSlug(slug, currentId = null) {
  const existing = await spaServiceRepository.findBySlug(slug, { includeInactive: true });
  if (existing && existing.id !== currentId) {
    throw new AppError('Service slug already exists.', 409, 'SERVICE_SLUG_EXISTS');
  }
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
    throw new AppError('Service slug is invalid.', 400, 'SERVICE_INVALID_SLUG');
  }
  return slug;
}

module.exports = {
  archiveSpaService,
  createSpaService,
  getSpaService,
  listAdminSpaServices,
  listSpaServices,
  updateSpaService,
};
