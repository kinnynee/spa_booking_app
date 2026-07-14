const { AppError } = require('../../common/errors/app-error');
const bookingModel = require('./booking.model');
const bookingRepository = require('./booking.repository');
const spaServiceRepository = require('../spa-services/spa-service.repository');
const spaSettingService = require('../spa-settings/spa-setting.service');
const userRepository = require('../users/user.repository');
const { Roles } = require('../../common/constants/roles');

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
  const availability = await getBookingAvailability(userId, payload);
  ensureBookable(availability);
  return createValidatedBooking(userId, payload);
}

async function createBookingForCustomer(payload) {
  const availability = await getBookingAvailability(payload.customerId, payload);
  ensureBookable(availability);
  const booking = await createValidatedBooking(payload.customerId, payload);
  return bookingRepository.findDetailedById(booking.id);
}

async function getBookingAvailability(userId, payload) {
  const [customer, service, settings] = await Promise.all([
    userRepository.findById(userId),
    spaServiceRepository.findById(payload.serviceId),
    spaSettingService.getBookingSettings(),
  ]);

  if (!customer || customer.role !== Roles.CUSTOMER || !customer.is_active) {
    return unavailable('CUSTOMER_NOT_ELIGIBLE', 'This account is not allowed to create bookings.');
  }
  if (!service) {
    return unavailable('SERVICE_NOT_AVAILABLE', 'This service is not available for booking.');
  }

  const appointmentTime = new Date(payload.appointmentTime);
  if (Number.isNaN(appointmentTime.getTime())) {
    return unavailable('INVALID_APPOINTMENT_TIME', 'The appointment time is invalid.');
  }

  const durationMinutes = Number(service.duration_minutes);
  const endsAt = new Date(appointmentTime.getTime() + durationMinutes * 60 * 1000);
  const leadMinutes = Number(settings.booking_lead_minutes || 0);
  if (appointmentTime.getTime() < Date.now() + leadMinutes * 60 * 1000) {
    return unavailable(
      'BOOKING_LEAD_TIME_NOT_MET',
      `Bookings must be made at least ${leadMinutes} minutes in advance.`,
    );
  }

  const localStart = toBusinessLocalTime(appointmentTime);
  const localEnd = toBusinessLocalTime(endsAt);
  if (localStart.day === 6 && !settings.is_open_saturday) {
    return unavailable('SPA_CLOSED_SATURDAY', 'The spa is closed on Saturday.');
  }
  if (localStart.day === 0 && !settings.is_open_sunday) {
    return unavailable('SPA_CLOSED_SUNDAY', 'The spa is closed on Sunday.');
  }

  const opensAt = toMinutes(settings.opening_time);
  const closesAt = toMinutes(settings.closing_time);
  if (
    localStart.minutes < opensAt ||
    localEnd.day !== localStart.day ||
    localEnd.minutes > closesAt
  ) {
    return unavailable(
      'OUTSIDE_WORKING_HOURS',
      `This ${durationMinutes}-minute service must finish during working hours.`,
    );
  }

  const hasConflict = await bookingRepository.hasUserTimeConflict(userId, appointmentTime, endsAt);
  if (hasConflict) {
    return unavailable('BOOKING_TIME_CONFLICT', 'You already have another booking during this time.');
  }

  return {
    canBook: true,
    reasonCode: null,
    reason: null,
    appointmentTime: appointmentTime.toISOString(),
    endsAt: endsAt.toISOString(),
    serviceDurationMinutes: durationMinutes,
    openingTime: settings.opening_time,
    closingTime: settings.closing_time,
  };
}

async function createValidatedBooking(userId, payload) {
  const service = await spaServiceRepository.findById(payload.serviceId);
  return bookingRepository.create({
    user_id: userId,
    service_id: service.id,
    appointment_time: new Date(payload.appointmentTime),
    note: payload.note,
    total_price: service.price,
    status: bookingModel.statuses.PENDING,
    payment_status: bookingModel.paymentStatuses.UNPAID,
  });
}

function ensureBookable(availability) {
  if (!availability.canBook) {
    throw new AppError(availability.reason, 400, availability.reasonCode);
  }
}

function unavailable(reasonCode, reason) {
  return { canBook: false, reasonCode, reason };
}

function toBusinessLocalTime(value) {
  const utcPlusSeven = new Date(value.getTime() + 7 * 60 * 60 * 1000);
  return {
    day: utcPlusSeven.getUTCDay(),
    minutes: utcPlusSeven.getUTCHours() * 60 + utcPlusSeven.getUTCMinutes(),
  };
}

function toMinutes(value) {
  const [hour, minute] = value.toString().split(':').map(Number);
  return hour * 60 + minute;
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
  createBookingForCustomer,
  getBookingAvailability,
  listBookings,
  listUserBookings,
  updateBookingPaymentStatus,
  updateBookingStatus,
};
