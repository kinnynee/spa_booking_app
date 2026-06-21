const bookingService = require('./booking.service');
const { sendCreated, sendSuccess } = require('../../common/utils/api-response');

async function createBooking(req, res) {
  const booking = await bookingService.createBooking(req.user.id, req.validated.body);
  return sendCreated(res, booking, 'Booking created.');
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

module.exports = {
  cancelBooking,
  createBooking,
  listMyBookings,
};
