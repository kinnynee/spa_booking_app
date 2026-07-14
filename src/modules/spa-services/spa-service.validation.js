const { z } = require('zod');

const uuid = z.string().uuid();
const price = z.coerce.number().nonnegative().max(100000000);

const servicePayload = z.object({
  categoryId: uuid,
  name: z.string().trim().min(2).max(160),
  slug: z.string().trim().min(2).max(180).optional(),
  description: z.string().trim().max(4000).optional().nullable(),
  price,
  durationMinutes: z.coerce.number().int().min(15).max(480),
  imageUrl: z.string().trim().url().max(500).optional().nullable(),
  isPopular: z.boolean().optional(),
  isActive: z.boolean().optional(),
});

const listSpaServicesSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z
    .object({
      categorySlug: z.string().trim().min(1).max(100).optional(),
      search: z.string().trim().min(1).max(100).optional(),
      minPrice: price.optional(),
      maxPrice: price.optional(),
    })
    .refine(
      (value) => value.minPrice === undefined || value.maxPrice === undefined || value.minPrice <= value.maxPrice,
      { message: 'minPrice cannot be greater than maxPrice.' },
    ),
});

const listAdminSpaServicesSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z
    .object({
      search: z.string().trim().max(100).optional(),
      status: z.enum(['active', 'inactive']).optional(),
      minPrice: price.optional(),
      maxPrice: price.optional(),
    })
    .refine(
      (value) => value.minPrice === undefined || value.maxPrice === undefined || value.minPrice <= value.maxPrice,
      { message: 'minPrice cannot be greater than maxPrice.' },
    ),
});

const createSpaServiceSchema = z.object({
  body: servicePayload,
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});

const updateSpaServiceSchema = z.object({
  body: servicePayload.partial().refine((value) => Object.keys(value).length > 0, {
    message: 'At least one field is required.',
  }),
  params: z.object({ id: uuid }),
  query: z.object({}).passthrough(),
});

const serviceIdSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({ id: uuid }),
  query: z.object({}).passthrough(),
});

module.exports = {
  createSpaServiceSchema,
  listAdminSpaServicesSchema,
  listSpaServicesSchema,
  serviceIdSchema,
  updateSpaServiceSchema,
};
