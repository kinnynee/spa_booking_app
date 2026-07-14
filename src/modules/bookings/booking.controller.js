const bookingService = require('./booking.service');
const { sendCreated, sendSuccess } = require('../../common/utils/api-response');

async function createBooking(req, res) {
  const booking = await bookingService.createBooking(req.user.id, req.validated.body);
  return sendCreated(res, booking, 'Booking created.');
}


async function createAdminBooking(req, res) {
  const booking = await bookingService.createBookingForCustomer(req.validated.body);
  return sendCreated(res, booking, 'Booking created.');
}

async function getBookingAvailability(req, res) {
  const availability = await bookingService.getBookingAvailability(req.user.id, req.validated.query);
  return sendSuccess(res, availability);
}
async function listBookings(req, res) {
  const bookings = await bookingService.listBookings(req.validated.query);
  return sendSuccess(res, bookings);
}

async function listMyBookings(req, res) {
  const bookings = await bookingService.listUserBookings(req.user.id);
  return sendSuccess(res, bookings);
}

async function cancelBooking(req, res) {
  const booking = await bookingService.cancelBooking(
    req.user.id,
    req.validated.params.id,
    req.validated.body.reason,
  );
  return sendSuccess(res, booking, 'Booking cancelled.');
}

async function updateBookingPaymentStatus(req, res) {
  const booking = await bookingService.updateBookingPaymentStatus(
    req.validated.params.id,
    req.validated.body.paymentStatus,
  );
  return sendSuccess(res, booking, 'Booking payment status updated.');
}

async function updateBookingStatus(req, res) {
  const booking = await bookingService.updateBookingStatus(
    req.user.id,
    req.validated.params.id,
    req.validated.body.status,
    req.validated.body.reason,
  );
  return sendSuccess(res, booking, 'Booking status updated.');
}

module.exports = {
  cancelBooking,
  createAdminBooking,
  createBooking,
  getBookingAvailability,
  listBookings,
  listMyBookings,
  updateBookingPaymentStatus,
  updateBookingStatus,
};
