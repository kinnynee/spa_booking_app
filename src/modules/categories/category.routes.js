const { Router } = require('express');

const categoryController = require('./category.controller');
const { Roles } = require('../../common/constants/roles');
const { authenticate, authorize } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const {
  categoryIdSchema,
  createCategorySchema,
  listAdminCategoriesSchema,
  updateCategorySchema,
} = require('./category.validation');

const router = Router();

router.get('/', asyncHandler(categoryController.listCategories));
router.get(
  '/admin',
  authenticate,
  authorize(Roles.ADMIN),
  validate(listAdminCategoriesSchema),
  asyncHandler(categoryController.listAdminCategories),
);
router.post(
  '/admin',
  authenticate,
  authorize(Roles.ADMIN),
  validate(createCategorySchema),
  asyncHandler(categoryController.createCategory),
);
router.patch(
  '/admin/:id',
  authenticate,
  authorize(Roles.ADMIN),
  validate(updateCategorySchema),
  asyncHandler(categoryController.updateCategory),
);
router.delete(
  '/admin/:id',
  authenticate,
  authorize(Roles.ADMIN),
  validate(categoryIdSchema),
  asyncHandler(categoryController.archiveCategory),
);

module.exports = router;
