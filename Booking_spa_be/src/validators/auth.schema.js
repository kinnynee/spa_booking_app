const { z } = require('zod');

const registerSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(8).max(128),
    displayName: z.string().min(2).max(80),
    phoneNumber: z.string().min(8).max(20).optional(),
  }),
});

module.exports = {
  registerSchema,
};
