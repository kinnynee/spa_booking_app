const { Router } = require('express');

const authRoutes = require('../modules/auth/auth.routes');
const bookingRoutes = require('../modules/bookings/booking.routes');
const categoryRoutes = require('../modules/categories/category.routes');
const healthRoutes = require('../modules/health/health.routes');
const profileRoutes = require('../modules/profiles/profile.routes');
const spaSettingRoutes = require('../modules/spa-settings/spa-setting.routes');
const spaServiceRoutes = require('../modules/spa-services/spa-service.routes');
const userRoutes = require('../modules/users/user.routes');

const router = Router();

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/profiles', profileRoutes);
router.use('/settings', spaSettingRoutes);
router.use('/categories', categoryRoutes);
router.use('/services', spaServiceRoutes);
router.use('/bookings', bookingRoutes);

module.exports = router;
