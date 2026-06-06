const sendResponse = (res, statusCode, success, message, data = null) => {
  return res.status(statusCode).json({
    success,
    message,
    data,
  });
};

const success = (res, message = 'Success', data = null, statusCode = 200) => {
  return sendResponse(res, statusCode, true, message, data);
};

const error = (res, message = 'Something went wrong', statusCode = 500, data = null) => {
  return sendResponse(res, statusCode, false, message, data);
};

module.exports = {
  sendResponse,
  success,
  error,
};
