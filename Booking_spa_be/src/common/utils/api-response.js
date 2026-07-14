function sendSuccess(res, data = null, message = 'OK', statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

function sendCreated(res, data = null, message = 'Created') {
  return sendSuccess(res, data, message, 201);
}

module.exports = {
  sendCreated,
  sendSuccess,
};
