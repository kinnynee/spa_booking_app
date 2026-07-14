const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const pipelineService = require('../services/pipeline.service');

const importCustomers = asyncHandler(async (req, res) => {
  const result = await pipelineService.importCustomers(req.body.items);
  return sendSuccess(res, {
    statusCode: 202,
    message: 'Customer import pipeline completed',
    data: result,
  });
});

module.exports = {
  importCustomers,
};
