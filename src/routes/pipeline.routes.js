const express = require('express');
const pipelineController = require('../controllers/pipeline.controller');
const validate = require('../middlewares/validate.middleware');
const { authenticate, authorizeRoles } = require('../middlewares/auth.middleware');
const { UserRoles } = require('../models/user.model');
const { importCustomersSchema } = require('../validators/pipeline.schema');

const router = express.Router();

router.post(
  '/customers/import',
  authenticate,
  authorizeRoles(UserRoles.ADMIN),
  validate(importCustomersSchema),
  pipelineController.importCustomers
);

module.exports = router;
