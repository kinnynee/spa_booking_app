const { z } = require('zod');

const registerSchema = z.object({
  body: z.object({
    fullName: z.string().trim().min(2).max(120),
    email: z.string().trim().email().toLowerCase(),
    phone: z.string().trim().min(8).max(20).optional(),
    password: z.string().min(8).max(72),
  }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

const loginSchema = z.object({
  body: z.object({
    email: z.string().trim().min(1).max(160).toLowerCase(),
    password: z.string().min(8).max(72),
  }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

const googleLoginSchema = z.object({
  body: z.object({
    idToken: z.string().trim().min(20).max(4096),
  }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

module.exports = {
  googleLoginSchema,
  loginSchema,
  registerSchema,
};
