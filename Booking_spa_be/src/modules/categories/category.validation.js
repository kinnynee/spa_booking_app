const { z } = require('zod');

const uuid = z.string().uuid();

const categoryPayload = z.object({
  name: z.string().trim().min(2).max(120),
  slug: z.string().trim().min(2).max(140).optional(),
  description: z.string().trim().max(500).optional().nullable(),
  sortOrder: z.coerce.number().int().min(0).max(9999).optional(),
  isActive: z.boolean().optional(),
});

const listAdminCategoriesSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z
    .object({
      search: z.string().trim().max(120).optional(),
      status: z.enum(['active', 'inactive']).optional(),
    })
    .passthrough(),
});

const createCategorySchema = z.object({
  body: categoryPayload,
  params: z.object({}).passthrough(),
  query: z.object({}).passthrough(),
});

const updateCategorySchema = z.object({
  body: categoryPayload.partial().refine((value) => Object.keys(value).length > 0, {
    message: 'At least one field is required.',
  }),
  params: z.object({ id: uuid }),
  query: z.object({}).passthrough(),
});

const categoryIdSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({ id: uuid }),
  query: z.object({}).passthrough(),
});

module.exports = {
  categoryIdSchema,
  createCategorySchema,
  listAdminCategoriesSchema,
  updateCategorySchema,
};
