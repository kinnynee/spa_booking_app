const { Router } = require('express');

const authController = require('./auth.controller');
const { authenticate } = require('../../common/middlewares/auth.middleware');
const { authRateLimiter } = require('../../common/middlewares/security.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const { googleLoginSchema, loginSchema, registerSchema } = require('./auth.validation');

const router = Router();

router.post('/register', authRateLimiter, validate(registerSchema), asyncHandler(authController.register));
router.post('/login', authRateLimiter, validate(loginSchema), asyncHandler(authController.login));
router.post('/google', authRateLimiter, validate(googleLoginSchema), asyncHandler(authController.googleLogin));
router.get('/me', authenticate, asyncHandler(authController.me));

module.exports = router;
