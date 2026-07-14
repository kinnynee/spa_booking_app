const { z } = require('zod');
const { ServiceCategories } = require('../models/spaService.model');

const serviceBody = z.object({
  name: z.string().min(2).max(120),
  category: z.enum(Object.values(ServiceCategories)),
  description: z.string().max(1000).optional(),
  price: z.number().positive(),
  durationMinutes: z.number().int().min(15).max(480),
  imageUrl: z.string().url().optional().or(z.literal('')),
  isPopular: z.boolean().optional(),
  isActive: z.boolean().optional(),
});

const createServiceSchema = z.object({
  body: serviceBody,
});

const updateServiceSchema = z.object({
  params: z.object({
    id: z.string().min(1),
  }),
  body: serviceBody.partial(),
});

const listServicesSchema = z.object({
  query: z.object({
    category: z.enum(Object.values(ServiceCategories)).optional(),
    isPopular: z
      .enum(['true', 'false'])
      .transform((value) => value === 'true')
      .optional(),
    limit: z.coerce.number().int().min(1).max(50).optional(),
    orderBy: z.enum(['createdAt', 'price', 'durationMinutes', 'name']).optional(),
  }),
});

module.exports = {
  createServiceSchema,
  listServicesSchema,
  updateServiceSchema,
};
