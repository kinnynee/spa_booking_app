const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const spaService = require('../services/spa.service');

const listServices = asyncHandler(async (req, res) => {
  const services = await spaService.listServices(req.query);
  return sendSuccess(res, {
    message: 'Services fetched successfully',
    data: services,
  });
});

const getServiceById = asyncHandler(async (req, res) => {
  const service = await spaService.getServiceById(req.params.id);
  return sendSuccess(res, {
    message: 'Service detail fetched successfully',
    data: service,
  });
});

const createService = asyncHandler(async (req, res) => {
  const service = await spaService.createService(req.body);
  return sendSuccess(res, {
    statusCode: 201,
    message: 'Service created successfully',
    data: service,
  });
});

const updateService = asyncHandler(async (req, res) => {
  const service = await spaService.updateService(req.params.id, req.body);
  return sendSuccess(res, {
    message: 'Service updated successfully',
    data: service,
  });
});

const deleteService = asyncHandler(async (req, res) => {
  const service = await spaService.deleteService(req.params.id);
  return sendSuccess(res, {
    message: 'Service disabled successfully',
    data: service,
  });
});

module.exports = {
  createService,
  deleteService,
  getServiceById,
  listServices,
  updateService,
};
