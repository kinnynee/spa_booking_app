const { z } = require('zod');

const updateProfileSchema = z.object({
  body: z.object({
    avatarUrl: z.string().url().optional().nullable(),
    birthDate: z.string().date().optional().nullable(),
    gender: z.enum(['male', 'female', 'other']).optional().nullable(),
    address: z.string().trim().max(255).optional().nullable(),
  }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

module.exports = {
  updateProfileSchema,
};
