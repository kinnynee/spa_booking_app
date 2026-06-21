const { z } = require('zod');

const listSpaServicesSchema = z.object({
  body: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
  query: z.object({
    categorySlug: z.string().trim().min(1).max(100).optional(),
    search: z.string().trim().min(1).max(100).optional(),
  }),
});

module.exports = {
  listSpaServicesSchema,
};
