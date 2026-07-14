function toAppointmentDto(appointment) {
  if (!appointment) return null;

  return {
    id: appointment.id,
    customerId: appointment.customerId,
    serviceId: appointment.serviceId,
    staffId: appointment.staffId || null,
    startAt: appointment.startAt,
    notes: appointment.notes || '',
    status: appointment.status,
    createdAt: appointment.createdAt,
    updatedAt: appointment.updatedAt,
  };
}

module.exports = {
  toAppointmentDto,
};
