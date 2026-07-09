const { AppError } = require('../../common/errors/app-error');
const bookingModel = require('./booking.model');
const bookingRepository = require('./booking.repository');
const spaServiceRepository = require('../spa-services/spa-service.repository');

const allowedStatusTransitions = Object.freeze({
  [bookingModel.statuses.PENDING]: [
    bookingModel.statuses.CONFIRMED,
    bookingModel.statuses.CANCELLED,
  ],
  [bookingModel.statuses.CONFIRMED]: [
    bookingModel.statuses.COMPLETED,
    bookingModel.statuses.CANCELLED,
  ],
  [bookingModel.statuses.COMPLETED]: [],
  [bookingModel.statuses.CANCELLED]: [],
});

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
    payment_status: bookingModel.paymentStatuses.UNPAID,
  });
}

async function listBookings(filters = {}) {
  return bookingRepository.list(filters);
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

  return bookingRepository.updateStatus(bookingId, bookingModel.statuses.CANCELLED, userId, reason);
}

async function updateBookingPaymentStatus(bookingId, paymentStatus) {
  const booking = await bookingRepository.findById(bookingId);

  if (!booking) {
    throw new AppError('Booking not found.', 404, 'BOOKING_NOT_FOUND');
  }

  if (booking.status === bookingModel.statuses.CANCELLED) {
    throw new AppError(
      'Cancelled bookings cannot be marked as paid.',
      400,
      'BOOKING_PAYMENT_NOT_ALLOWED',
    );
  }

  if (booking.payment_status === paymentStatus) {
    return bookingRepository.findDetailedById(bookingId);
  }

  await bookingRepository.updatePaymentStatus(bookingId, paymentStatus);
  return bookingRepository.findDetailedById(bookingId);
}

async function updateBookingStatus(adminUserId, bookingId, status, reason) {
  const booking = await bookingRepository.findById(bookingId);

  if (!booking) {
    throw new AppError('Booking not found.', 404, 'BOOKING_NOT_FOUND');
  }

  if (booking.status === status) {
    return bookingRepository.findDetailedById(bookingId);
  }

  const allowedNextStatuses = allowedStatusTransitions[booking.status] ?? [];
  if (!allowedNextStatuses.includes(status)) {
    throw new AppError(
      'This booking status transition is not allowed.',
      400,
      'BOOKING_STATUS_TRANSITION_NOT_ALLOWED',
    );
  }

  await bookingRepository.updateStatus(bookingId, status, adminUserId, reason);
  return bookingRepository.findDetailedById(bookingId);
}

module.exports = {
  cancelBooking,
  createBooking,
  listBookings,
  listUserBookings,
  updateBookingPaymentStatus,
  updateBookingStatus,
};
