const { z } = require('zod');

const bookingModel = require('./booking.model');

const uuid = z.string().uuid();
const bookingStatuses = Object.values(bookingModel.statuses);
const paymentStatuses = Object.values(bookingModel.paymentStatuses);

const createBookingSchema = z.object({
  body: z.object({
    serviceId: uuid,
    appointmentTime: z.string().datetime(),
    note: z.string().trim().max(500).optional(),
  }),
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});


const createAdminBookingSchema = z.object({
  body: z.object({
    customerId: uuid,
    serviceId: uuid,
    appointmentTime: z.string().datetime(),
    note: z.string().trim().max(500).optional(),
  }),
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});

const bookingAvailabilitySchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z.object({
    serviceId: uuid,
    appointmentTime: z.string().datetime(),
  }),
});
const listBookingsSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z
    .object({
      status: z.enum(bookingStatuses).optional(),
      paymentStatus: z.enum(paymentStatuses).optional(),
      search: z.string().trim().max(120).optional(),
      limit: z.coerce.number().int().min(1).max(100).optional(),
      offset: z.coerce.number().int().min(0).optional(),
    })
    .passthrough(),
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

const updateBookingStatusSchema = z.object({
  body: z.object({
    status: z.enum(bookingStatuses),
    reason: z.string().trim().max(255).optional(),
  }),
  params: z.object({
    id: uuid,
  }),
  query: z.object({}).passthrough(),
});

const updateBookingPaymentStatusSchema = z.object({
  body: z.object({
    paymentStatus: z.enum(paymentStatuses),
  }),
  params: z.object({
    id: uuid,
  }),
  query: z.object({}).passthrough(),
});

module.exports = {
  cancelBookingSchema,
  bookingAvailabilitySchema,
  createAdminBookingSchema,
  createBookingSchema,
  listBookingsSchema,
  updateBookingPaymentStatusSchema,
  updateBookingStatusSchema,
};
