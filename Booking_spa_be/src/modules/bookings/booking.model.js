const BookingStatus = Object.freeze({
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  CANCELLED: 'cancelled',
  COMPLETED: 'completed',
});

const PaymentStatus = Object.freeze({
  UNPAID: 'unpaid',
  PAID: 'paid',
});

const bookingModel = Object.freeze({
  paymentStatuses: PaymentStatus,
  tableName: 'bookings',
  statuses: BookingStatus,
});

module.exports = bookingModel;
