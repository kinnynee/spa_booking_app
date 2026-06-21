const { z } = require('zod');

const importCustomersSchema = z.object({
  body: z.object({
    items: z.array(z.record(z.any())).min(1).max(500),
  }),
});

module.exports = {
  importCustomersSchema,
};
