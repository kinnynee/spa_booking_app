const { z } = require('zod');
const { AppointmentStatus } = require('../models/appointment.model');

const createAppointmentSchema = z.object({
  body: z.object({
    serviceId: z.string().min(1),
    staffId: z.string().min(1).optional(),
    startAt: z.string().datetime(),
    notes: z.string().max(500).optional(),
  }),
});

const listAppointmentSchema = z.object({
  query: z.object({
    limit: z.coerce.number().int().min(1).max(100).optional(),
    customerId: z.string().min(1).optional(),
    staffId: z.string().min(1).optional(),
  }),
});

const appointmentIdSchema = z.object({
  params: z.object({
    id: z.string().min(1),
  }),
});

const updateAppointmentStatusSchema = z.object({
  params: z.object({
    id: z.string().min(1),
  }),
  body: z.object({
    status: z.enum(Object.values(AppointmentStatus)),
  }),
});

module.exports = {
  appointmentIdSchema,
  createAppointmentSchema,
  listAppointmentSchema,
  updateAppointmentStatusSchema,
};
