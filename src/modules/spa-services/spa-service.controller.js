const spaServiceService = require('./spa-service.service');
const { sendSuccess } = require('../../common/utils/api-response');

async function listSpaServices(req, res) {
  const services = await spaServiceService.listSpaServices(req.validated.query);
  return sendSuccess(res, services);
}

async function getSpaService(req, res) {
  const service = await spaServiceService.getSpaService(req.params.id);
  return sendSuccess(res, service);
}

module.exports = {
  getSpaService,
  listSpaServices,
};
