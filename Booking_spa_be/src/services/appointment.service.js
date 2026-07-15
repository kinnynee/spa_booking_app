const createError = require('http-errors');
const appointmentRepository = require('../repositories/appointment.repository');
const serviceRepository = require('../repositories/service.repository');
const { buildAppointmentModel, AppointmentStatus } = require('../models/appointment.model');
const { UserRoles } = require('../models/user.model');
const { toAppointmentDto } = require('../dto/appointment.dto');
const eventBus = require('../events/eventBus');
const eventTypes = require('../events/eventTypes');

function assertFutureDate(startAt) {
  if (new Date(startAt).getTime() <= Date.now()) {
    throw createError(400, 'Appointment time must be in the future');
  }
}

function canAccessAppointment(user, appointment) {
  if (user.role === UserRoles.ADMIN) return true;
  if (user.role === UserRoles.STAFF && appointment.staffId === user.uid) return true;
  return appointment.customerId === user.uid;
}

async function createAppointment(authUser, payload) {
  assertFutureDate(payload.startAt);

  const service = await serviceRepository.findById(payload.serviceId);
  if (!service || service.isActive === false) throw createError(404, 'Service not found');

  const appointment = await appointmentRepository.createAppointment(
    buildAppointmentModel({
      ...payload,
      customerId: authUser.uid,
    })
  );

  eventBus.emit(eventTypes.APPOINTMENT_CREATED, {
    appointmentId: appointment.id,
    customerId: appointment.customerId,
  });

  return toAppointmentDto(appointment);
}

async function listAppointments(authUser, query = {}) {
  const limit = query.limit || 20;

  if (authUser.role === UserRoles.ADMIN) {
    if (query.customerId) {
      return (await appointmentRepository.listForCustomer(query.customerId, { limit })).map(
        toAppointmentDto
      );
    }

    if (query.staffId) {
      return (await appointmentRepository.listForStaff(query.staffId, { limit })).map(toAppointmentDto);
    }

    return (await appointmentRepository.list({ limit, orderBy: 'startAt' })).map(toAppointmentDto);
  }

  if (authUser.role === UserRoles.STAFF) {
    return (await appointmentRepository.listForStaff(authUser.uid, { limit })).map(toAppointmentDto);
  }

  return (await appointmentRepository.listForCustomer(authUser.uid, { limit })).map(toAppointmentDto);
}

async function getAppointment(authUser, id) {
  const appointment = await appointmentRepository.findById(id);
  if (!appointment) throw createError(404, 'Appointment not found');
  if (!canAccessAppointment(authUser, appointment)) throw createError(403, 'Forbidden');

  return toAppointmentDto(appointment);
}

async function updateStatus(authUser, id, status) {
  const appointment = await appointmentRepository.findById(id);
  if (!appointment) throw createError(404, 'Appointment not found');
  if (authUser.role === UserRoles.STAFF && appointment.staffId !== authUser.uid) {
    throw createError(403, 'Forbidden');
  }

  const updatedAppointment = await appointmentRepository.updateStatus(id, status);
  eventBus.emit(eventTypes.APPOINTMENT_STATUS_CHANGED, {
    appointmentId: id,
    status,
  });

  return toAppointmentDto(updatedAppointment);
}

async function cancelAppointment(authUser, id) {
  const appointment = await appointmentRepository.findById(id);
  if (!appointment) throw createError(404, 'Appointment not found');
  if (!canAccessAppointment(authUser, appointment)) throw createError(403, 'Forbidden');
  if ([AppointmentStatus.CANCELLED, AppointmentStatus.COMPLETED].includes(appointment.status)) {
    throw createError(400, 'Appointment cannot be cancelled');
  }

  const updatedAppointment = await appointmentRepository.updateStatus(id, AppointmentStatus.CANCELLED);
  eventBus.emit(eventTypes.APPOINTMENT_STATUS_CHANGED, {
    appointmentId: id,
    status: AppointmentStatus.CANCELLED,
  });

  return toAppointmentDto(updatedAppointment);
}

module.exports = {
  cancelAppointment,
  createAppointment,
  getAppointment,
  listAppointments,
  updateStatus,
};
