const { Router } = require('express');

const userController = require('./user.controller');
const { Roles } = require('../../common/constants/roles');
const { authenticate, authorize } = require('../../common/middlewares/auth.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');

const router = Router();

router.get('/', authenticate, authorize(Roles.ADMIN), asyncHandler(userController.listUsers));
router.get('/:id', authenticate, authorize(Roles.ADMIN, Roles.STAFF), asyncHandler(userController.getUser));

module.exports = router;
