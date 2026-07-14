const express = require('express');
const appointmentController = require('../controllers/appointment.controller');
const validate = require('../middlewares/validate.middleware');
const { authenticate, authorizeRoles } = require('../middlewares/auth.middleware');
const { UserRoles } = require('../models/user.model');
const {
  appointmentIdSchema,
  createAppointmentSchema,
  listAppointmentSchema,
  updateAppointmentStatusSchema,
} = require('../validators/appointment.schema');

const router = express.Router();

router.use(authenticate);

router.get('/', validate(listAppointmentSchema), appointmentController.listAppointments);
router.post('/', validate(createAppointmentSchema), appointmentController.createAppointment);
router.get('/:id', validate(appointmentIdSchema), appointmentController.getAppointment);
router.patch('/:id/cancel', validate(appointmentIdSchema), appointmentController.cancelAppointment);
router.patch(
  '/:id/status',
  authorizeRoles(UserRoles.ADMIN, UserRoles.STAFF),
  validate(updateAppointmentStatusSchema),
  appointmentController.updateAppointmentStatus
);

module.exports = router;
