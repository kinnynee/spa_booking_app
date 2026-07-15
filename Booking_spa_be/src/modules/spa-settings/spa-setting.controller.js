const { sendSuccess } = require('../../common/utils/api-response');
const spaSettingService = require('./spa-setting.service');

async function getBookingSettings(_req, res) {
  const settings = await spaSettingService.getBookingSettings();
  return sendSuccess(res, spaSettingService.toBookingSettingsDto(settings));
}

async function updateBookingSettings(req, res) {
  const settings = await spaSettingService.updateBookingSettings(req.validated.body);
  return sendSuccess(res, spaSettingService.toBookingSettingsDto(settings), 'Spa settings updated.');
}

module.exports = {
  getBookingSettings,
  updateBookingSettings,
};
