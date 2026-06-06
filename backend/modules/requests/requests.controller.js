const service = require('./requests.service');

const sendSuccess = (res, statusCode, message, data, extra = {}) => {
  return res.status(statusCode).json({
    success: true,
    message,
    ...extra,
    data,
  });
};

const getIncoming = async (req, res, next) => {
  try {
    const data = await service.getIncoming(req.user.studentId);
    return sendSuccess(res, 200, 'Incoming requests fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const getOutgoing = async (req, res, next) => {
  try {
    const data = await service.getOutgoing(req.user.studentId);
    return sendSuccess(res, 200, 'Outgoing requests fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const send = async (req, res, next) => {
  try {
    const data = await service.sendRequest(req.body, req.user.studentId);
    return sendSuccess(res, 201, 'Request sent successfully', data);
  } catch (err) {
    return next(err);
  }
};

const update = async (req, res, next) => {
  try {
    const { status } = req.body;

    if (status === 'accepted') {
      const data = await service.acceptRequest(req.params.id, req.user.studentId);
      return sendSuccess(res, 200, 'Request accepted successfully', data);
    }

    if (status === 'rejected') {
      const data = await service.rejectRequest(req.params.id, req.user.studentId);
      return sendSuccess(res, 200, 'Request rejected successfully', data);
    }

    const err = new Error('status must be accepted or rejected');
    err.statusCode = 400;
    throw err;
  } catch (err) {
    return next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    await service.cancelRequest(req.params.id, req.user.studentId);
    return sendSuccess(res, 200, 'Request cancelled successfully', null);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getIncoming,
  getOutgoing,
  send,
  update,
  remove,
};
