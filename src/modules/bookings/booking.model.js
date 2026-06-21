const BookingStatus = Object.freeze({
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  CANCELLED: 'cancelled',
  COMPLETED: 'completed',
});

const bookingModel = Object.freeze({
  tableName: 'bookings',
  statuses: BookingStatus,
});

module.exports = bookingModel;
