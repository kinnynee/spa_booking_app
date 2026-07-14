const express = require('express');
const { Router } = express;

const spaServiceController = require('./spa-service.controller');
const { Roles } = require('../../common/constants/roles');
const { authenticate, authorize } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const {
  createSpaServiceSchema,
  listAdminSpaServicesSchema,
  listSpaServicesSchema,
  serviceIdSchema,
  updateSpaServiceSchema,
} = require('./spa-service.validation');

const router = Router();

router.get('/', validate(listSpaServicesSchema), asyncHandler(spaServiceController.listSpaServices));
router.get(
  '/admin',
  authenticate,
  authorize(Roles.ADMIN),
  validate(listAdminSpaServicesSchema),
  asyncHandler(spaServiceController.listAdminSpaServices),
);
router.post(
  '/admin/image',
  authenticate,
  authorize(Roles.ADMIN),
  express.raw({ type: ['image/jpeg', 'image/png', 'image/webp'], limit: '5mb' }),
  asyncHandler(spaServiceController.uploadSpaServiceImage),
);
router.post(
  '/admin',
  authenticate,
  authorize(Roles.ADMIN),
  validate(createSpaServiceSchema),
  asyncHandler(spaServiceController.createSpaService),
);
router.patch(
  '/admin/:id',
  authenticate,
  authorize(Roles.ADMIN),
  validate(updateSpaServiceSchema),
  asyncHandler(spaServiceController.updateSpaService),
);
router.delete(
  '/admin/:id',
  authenticate,
  authorize(Roles.ADMIN),
  validate(serviceIdSchema),
  asyncHandler(spaServiceController.archiveSpaService),
);
router.get('/:id', asyncHandler(spaServiceController.getSpaService));

module.exports = router;