const express = require('express');
const authController = require('../controllers/auth.controller');
const validate = require('../middlewares/validate.middleware');
const { authenticate } = require('../middlewares/auth.middleware');
const { registerSchema } = require('../validators/auth.schema');

const router = express.Router();

router.post('/register', validate(registerSchema), authController.register);
router.get('/me', authenticate, authController.me);

module.exports = router;
