const { AppError } = require('../../common/errors/app-error');
const spaServiceRepository = require('./spa-service.repository');
const { toSpaServiceDto } = require('./spa-service.dto');

async function listSpaServices(filters) {
  const services = await spaServiceRepository.list(filters);
  return services.map(toSpaServiceDto);
}

async function getSpaService(id) {
  const service = await spaServiceRepository.findById(id);

  if (!service) {
    throw new AppError('Service not found.', 404, 'SERVICE_NOT_FOUND');
  }

  return toSpaServiceDto(service);
}

module.exports = {
  getSpaService,
  listSpaServices,
};
