const { AppError } = require('../../common/errors/app-error');
const bookingModel = require('./booking.model');
const bookingRepository = require('./booking.repository');
const spaServiceRepository = require('../spa-services/spa-service.repository');

async function createBooking(userId, payload) {
  const service = await spaServiceRepository.findById(payload.serviceId);

  if (!service) {
    throw new AppError('Service not found.', 404, 'SERVICE_NOT_FOUND');
  }

  const appointmentTime = new Date(payload.appointmentTime);

  if (appointmentTime <= new Date()) {
    throw new AppError('Appointment time must be in the future.', 400, 'INVALID_APPOINTMENT_TIME');
  }

  return bookingRepository.create({
    user_id: userId,
    service_id: service.id,
    appointment_time: appointmentTime,
    note: payload.note,
    total_price: service.price,
    status: bookingModel.statuses.PENDING,
  });
}

async function listUserBookings(userId) {
  return bookingRepository.listByUserId(userId);
}

async function cancelBooking(userId, bookingId, reason) {
  const booking = await bookingRepository.findById(bookingId);

  if (!booking || booking.user_id !== userId) {
    throw new AppError('Booking not found.', 404, 'BOOKING_NOT_FOUND');
  }

  if (![bookingModel.statuses.PENDING, bookingModel.statuses.CONFIRMED].includes(booking.status)) {
    throw new AppError('This booking cannot be cancelled.', 400, 'BOOKING_NOT_CANCELLABLE');
  }

  return bookingRepository.updateStatus(
    bookingId,
    bookingModel.statuses.CANCELLED,
    userId,
    reason,
  );
}

module.exports = {
  cancelBooking,
  createBooking,
  listUserBookings,
};
