const express = require('express');
const userController = require('../controllers/user.controller');
const validate = require('../middlewares/validate.middleware');
const upload = require('../middlewares/upload.middleware');
const { authenticate, authorizeRoles } = require('../middlewares/auth.middleware');
const { UserRoles } = require('../models/user.model');
const { setRoleSchema, updateMeSchema } = require('../validators/user.schema');

const router = express.Router();

router.use(authenticate);

router.get('/me', userController.getMe);
router.patch('/me', validate(updateMeSchema), userController.updateMe);
router.post('/me/avatar', upload.single('avatar'), userController.uploadAvatar);

router.get('/', authorizeRoles(UserRoles.ADMIN), userController.listUsers);
router.patch(
  '/:uid/role',
  authorizeRoles(UserRoles.ADMIN),
  validate(setRoleSchema),
  userController.setUserRole
);

module.exports = router;
