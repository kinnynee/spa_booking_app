const { z } = require('zod');
const { UserRoles } = require('../models/user.model');

const updateMeSchema = z.object({
  body: z.object({
    displayName: z.string().min(2).max(80).optional(),
    phoneNumber: z.string().min(8).max(20).optional(),
    photoURL: z.string().url().optional().or(z.literal('')),
    dateOfBirth: z.string().date().optional().nullable(),
    gender: z.enum(['male', 'female', 'other', '']).optional(),
  }),
});

const setRoleSchema = z.object({
  params: z.object({
    uid: z.string().min(1),
  }),
  body: z.object({
    role: z.enum(Object.values(UserRoles)),
  }),
});

module.exports = {
  setRoleSchema,
  updateMeSchema,
};
