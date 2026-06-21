const { Router } = require('express');

const healthController = require('./health.controller');
const { asyncHandler } = require('../../common/utils/async-handler');

const router = Router();

router.get('/', asyncHandler(healthController.liveness));
router.get('/ready', asyncHandler(healthController.readiness));

module.exports = router;
