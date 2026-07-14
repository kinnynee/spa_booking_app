const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const appointmentService = require('../services/appointment.service');

const createAppointment = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.createAppointment(req.user, req.body);
  return sendSuccess(res, {
    statusCode: 201,
    message: 'Appointment created successfully',
    data: appointment,
  });
});

const listAppointments = asyncHandler(async (req, res) => {
  const appointments = await appointmentService.listAppointments(req.user, req.query);
  return sendSuccess(res, {
    message: 'Appointments fetched successfully',
    data: appointments,
  });
});

const getAppointment = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.getAppointment(req.user, req.params.id);
  return sendSuccess(res, {
    message: 'Appointment detail fetched successfully',
    data: appointment,
  });
});

const updateAppointmentStatus = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.updateStatus(req.user, req.params.id, req.body.status);
  return sendSuccess(res, {
    message: 'Appointment status updated successfully',
    data: appointment,
  });
});

const cancelAppointment = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.cancelAppointment(req.user, req.params.id);
  return sendSuccess(res, {
    message: 'Appointment cancelled successfully',
    data: appointment,
  });
});

module.exports = {
  cancelAppointment,
  createAppointment,
  getAppointment,
  listAppointments,
  updateAppointmentStatus,
};
