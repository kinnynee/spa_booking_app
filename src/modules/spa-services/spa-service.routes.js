const { Router } = require('express');

const spaServiceController = require('./spa-service.controller');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const { listSpaServicesSchema } = require('./spa-service.validation');

const router = Router();

router.get('/', validate(listSpaServicesSchema), asyncHandler(spaServiceController.listSpaServices));
router.get('/:id', asyncHandler(spaServiceController.getSpaService));

module.exports = router;
