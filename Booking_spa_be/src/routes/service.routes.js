const express = require('express');
const serviceController = require('../controllers/service.controller');
const validate = require('../middlewares/validate.middleware');
const { authenticate, authorizeRoles } = require('../middlewares/auth.middleware');
const { UserRoles } = require('../models/user.model');
const {
  createServiceSchema,
  listServicesSchema,
  updateServiceSchema,
} = require('../validators/service.schema');

const router = express.Router();

router.get('/', validate(listServicesSchema), serviceController.listServices);
router.get('/:id', serviceController.getServiceById);
router.post(
  '/',
  authenticate,
  authorizeRoles(UserRoles.ADMIN),
  validate(createServiceSchema),
  serviceController.createService
);
router.patch(
  '/:id',
  authenticate,
  authorizeRoles(UserRoles.ADMIN),
  validate(updateServiceSchema),
  serviceController.updateService
);
router.delete(
  '/:id',
  authenticate,
  authorizeRoles(UserRoles.ADMIN),
  serviceController.deleteService
);

module.exports = router;
