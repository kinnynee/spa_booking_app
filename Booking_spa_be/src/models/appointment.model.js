const AppointmentStatus = Object.freeze({
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  CANCELLED: 'cancelled',
  COMPLETED: 'completed',
});

function buildAppointmentModel(payload) {
  return {
    customerId: payload.customerId,
    serviceId: payload.serviceId,
    staffId: payload.staffId || null,
    startAt: payload.startAt,
    notes: payload.notes || '',
    status: AppointmentStatus.PENDING,
  };
}

module.exports = {
  AppointmentStatus,
  buildAppointmentModel,
};
