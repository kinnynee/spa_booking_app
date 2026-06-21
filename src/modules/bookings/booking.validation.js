const { z } = require('zod');

const uuid = z.string().uuid();

const createBookingSchema = z.object({
  body: z.object({
    serviceId: uuid,
    appointmentTime: z.string().datetime(),
    note: z.string().trim().max(500).optional(),
  }),
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});

const cancelBookingSchema = z.object({
  body: z.object({
    reason: z.string().trim().max(255).optional(),
  }),
  params: z.object({
    id: uuid,
  }),
  query: z.object({}).passthrough(),
});

module.exports = {
  cancelBookingSchema,
  createBookingSchema,
};
