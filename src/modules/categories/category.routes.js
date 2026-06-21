const { Router } = require('express');

const categoryController = require('./category.controller');
const { asyncHandler } = require('../../common/utils/async-handler');

const router = Router();

router.get('/', asyncHandler(categoryController.listCategories));

module.exports = router;
