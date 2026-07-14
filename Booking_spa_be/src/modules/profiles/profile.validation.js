const { z } = require('zod');

const updateProfileSchema = z.object({
  body: z
    .object({
      fullName: z.string().trim().min(2).max(120).optional(),
      phone: z.string().trim().min(6).max(30).optional().nullable(),
      avatarUrl: z.string().url().max(500).optional().nullable(),
      birthDate: z.string().date().optional().nullable(),
      gender: z.enum(['male', 'female', 'other']).optional().nullable(),
      address: z.string().trim().max(255).optional().nullable(),
    })
    .refine((value) => Object.keys(value).length > 0, {
      message: 'At least one profile field is required.',
    }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

module.exports = {
  updateProfileSchema,
};
