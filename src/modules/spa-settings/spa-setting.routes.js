const { Router } = require('express');

const { Roles } = require('../../common/constants/roles');
const { authenticate, authorize } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const spaSettingController = require('./spa-setting.controller');
const { updateBookingSettingsSchema } = require('./spa-setting.validation');

const router = Router();

router.get('/booking', asyncHandler(spaSettingController.getBookingSettings));
router.patch(
  '/booking',
  authenticate,
  authorize(Roles.ADMIN),
  validate(updateBookingSettingsSchema),
  asyncHandler(spaSettingController.updateBookingSettings),
);

module.exports = router;
