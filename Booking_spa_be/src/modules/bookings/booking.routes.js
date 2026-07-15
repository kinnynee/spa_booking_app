const { Router } = require('express');

const bookingController = require('./booking.controller');
const { Roles } = require('../../common/constants/roles');
const { authenticate, authorize } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const {
  cancelBookingSchema,
  bookingAvailabilitySchema,
  createBookingSchema,
  createAdminBookingSchema,
  listBookingsSchema,
  updateBookingPaymentStatusSchema,
  updateBookingStatusSchema,
} = require('./booking.validation');

const router = Router();

router.use(authenticate);

router.get(
  '/availability',
  validate(bookingAvailabilitySchema),
  asyncHandler(bookingController.getBookingAvailability),
);
router.post('/', validate(createBookingSchema), asyncHandler(bookingController.createBooking));
router.post(
  '/admin',
  authorize(Roles.ADMIN),
  validate(createAdminBookingSchema),
  asyncHandler(bookingController.createAdminBooking),
);
router.get(
  '/',
  authorize(Roles.ADMIN),
  validate(listBookingsSchema),
  asyncHandler(bookingController.listBookings),
);
router.get('/me', asyncHandler(bookingController.listMyBookings));
router.patch(
  '/:id/payment-status',
  authorize(Roles.ADMIN),
  validate(updateBookingPaymentStatusSchema),
  asyncHandler(bookingController.updateBookingPaymentStatus),
);
router.patch(
  '/:id/status',
  authorize(Roles.ADMIN),
  validate(updateBookingStatusSchema),
  asyncHandler(bookingController.updateBookingStatus),
);
router.patch(
  '/:id/cancel',
  validate(cancelBookingSchema),
  asyncHandler(bookingController.cancelBooking),
);

module.exports = router;
