const { AppError } = require('../../common/errors/app-error');
const spaSettingRepository = require('./spa-setting.repository');

async function getBookingSettings() {
  const settings = await spaSettingRepository.find();
  if (!settings) {
    throw new AppError('Spa settings are not configured.', 500, 'SPA_SETTINGS_MISSING');
  }
  return settings;
}

async function updateBookingSettings(payload) {
  const nextPayload = {};
  const fields = {
    spaName: 'spa_name',
    address: 'address',
    hotline: 'hotline',
    contactEmail: 'contact_email',
    openingTime: 'opening_time',
    closingTime: 'closing_time',
    isOpenSaturday: 'is_open_saturday',
    isOpenSunday: 'is_open_sunday',
    bookingLeadMinutes: 'booking_lead_minutes',
    bannerTitle: 'banner_title',
    bannerSubtitle: 'banner_subtitle',
    bannerImageUrl: 'banner_image_url',
  };

  for (const [inputKey, column] of Object.entries(fields)) {
    if (payload[inputKey] !== undefined) {
      nextPayload[column] = payload[inputKey];
    }
  }

  const settings = await spaSettingRepository.update(nextPayload);
  if (!settings) {
    throw new AppError('Spa settings are not configured.', 500, 'SPA_SETTINGS_MISSING');
  }
  return settings;
}

function toBookingSettingsDto(settings) {
  return {
    spaName: settings.spa_name,
    address: settings.address || '',
    hotline: settings.hotline || '',
    contactEmail: settings.contact_email || '',
    openingTime: settings.opening_time,
    closingTime: settings.closing_time,
    isOpenSaturday: settings.is_open_saturday,
    isOpenSunday: settings.is_open_sunday,
    bookingLeadMinutes: settings.booking_lead_minutes,
    bannerTitle: settings.banner_title,
    bannerSubtitle: settings.banner_subtitle,
    bannerImageUrl: settings.banner_image_url || '',
  };
}

module.exports = {
  getBookingSettings,
  toBookingSettingsDto,
  updateBookingSettings,
};
