const spaServiceService = require('./spa-service.service');
const { saveServiceImage } = require('./spa-service-image-upload');
const { sendSuccess } = require('../../common/utils/api-response');

async function listSpaServices(req, res) {
  const services = await spaServiceService.listSpaServices(req.validated.query);
  return sendSuccess(res, services);
}

async function getSpaService(req, res) {
  const service = await spaServiceService.getSpaService(req.params.id);
  return sendSuccess(res, service);
}

async function listAdminSpaServices(req, res) {
  const services = await spaServiceService.listAdminSpaServices(req.validated.query);
  return sendSuccess(res, services);
}

async function createSpaService(req, res) {
  const service = await spaServiceService.createSpaService(req.validated.body);
  return sendSuccess(res, service, 'Service created.', 201);
}

async function uploadSpaServiceImage(req, res) {
  const fileName = await saveServiceImage({
    buffer: req.body,
    contentType: req.get('content-type') || '',
  });
  const imageUrl = `${req.protocol}://${req.get('host')}/static/uploads/services/${fileName}`;
  return sendSuccess(res, { imageUrl }, 'Service image uploaded.', 201);
}

async function updateSpaService(req, res) {
  const service = await spaServiceService.updateSpaService(
    req.validated.params.id,
    req.validated.body,
  );
  return sendSuccess(res, service, 'Service updated.');
}

async function archiveSpaService(req, res) {
  const service = await spaServiceService.archiveSpaService(req.validated.params.id);
  return sendSuccess(res, service, 'Service archived.');
}

module.exports = {
  archiveSpaService,
  createSpaService,
  getSpaService,
  listAdminSpaServices,
  listSpaServices,
  updateSpaService,
  uploadSpaServiceImage,
};