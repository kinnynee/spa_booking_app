const { z } = require('zod');

const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Time must use HH:mm.');

const updateBookingSettingsSchema = z.object({
  body: z
    .object({
      spaName: z.string().trim().min(2).max(140).optional(),
      address: z.string().trim().max(255).optional().nullable(),
      hotline: z.string().trim().max(30).optional().nullable(),
      contactEmail: z.string().trim().email().max(160).optional().nullable(),
      openingTime: time.optional(),
      closingTime: time.optional(),
      isOpenSaturday: z.boolean().optional(),
      isOpenSunday: z.boolean().optional(),
      bookingLeadMinutes: z.number().int().min(0).max(1440).optional(),
      bannerTitle: z.string().trim().min(2).max(140).optional(),
      bannerSubtitle: z.string().trim().min(2).max(255).optional(),
      bannerImageUrl: z.string().trim().url().max(500).optional().nullable(),
    })
    .refine((value) => Object.keys(value).length > 0, {
      message: 'At least one setting is required.',
    }),
  query: z.object({}).passthrough(),
  params: z.object({}).passthrough(),
});

module.exports = {
  updateBookingSettingsSchema,
};
