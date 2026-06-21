const { Router } = require('express');

const profileController = require('./profile.controller');
const { authenticate } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const { updateProfileSchema } = require('./profile.validation');

const router = Router();

router.get('/me', authenticate, asyncHandler(profileController.getMyProfile));
router.put(
  '/me',
  authenticate,
  validate(updateProfileSchema),
  asyncHandler(profileController.updateMyProfile),
);

module.exports = router;
