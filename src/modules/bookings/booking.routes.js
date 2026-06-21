const { Router } = require('express');

const bookingController = require('./booking.controller');
const { authenticate } = require('../../common/middlewares/auth.middleware');
const { validate } = require('../../common/middlewares/validate.middleware');
const { asyncHandler } = require('../../common/utils/async-handler');
const { cancelBookingSchema, createBookingSchema } = require('./booking.validation');

const router = Router();

router.use(authenticate);

router.post('/', validate(createBookingSchema), asyncHandler(bookingController.createBooking));
router.get('/me', asyncHandler(bookingController.listMyBookings));
router.patch('/:id/cancel', validate(cancelBookingSchema), asyncHandler(bookingController.cancelBooking));

module.exports = router;
