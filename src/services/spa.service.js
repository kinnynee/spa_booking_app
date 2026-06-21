const createError = require('http-errors');
const serviceRepository = require('../repositories/service.repository');
const { buildSpaServiceModel } = require('../models/spaService.model');
const { toServiceDto } = require('../dto/service.dto');
const cacheService = require('./cache.service');

function getServiceListCacheKey(query) {
  return `services:${JSON.stringify(query)}`;
}

async function listServices(query = {}) {
  const cacheKey = getServiceListCacheKey(query);
  const cached = await cacheService.getJson(cacheKey);
  if (cached) return cached;

  const services = await serviceRepository.listServices(query);
  const dto = services.map(toServiceDto);
  await cacheService.setJson(cacheKey, dto);
  return dto;
}

async function getServiceById(id) {
  const service = await serviceRepository.findById(id);
  if (!service || service.isActive === false) throw createError(404, 'Service not found');
  return toServiceDto(service);
}

async function createService(payload) {
  const service = await serviceRepository.create(buildSpaServiceModel(payload));
  return toServiceDto(service);
}

async function updateService(id, payload) {
  const existing = await serviceRepository.findById(id);
  if (!existing) throw createError(404, 'Service not found');

  const updated = await serviceRepository.update(id, payload);
  return toServiceDto(updated);
}

async function deleteService(id) {
  const existing = await serviceRepository.findById(id);
  if (!existing) throw createError(404, 'Service not found');

  const updated = await serviceRepository.update(id, { isActive: false });
  return toServiceDto(updated);
}

module.exports = {
  createService,
  deleteService,
  getServiceById,
  listServices,
  updateService,
};
