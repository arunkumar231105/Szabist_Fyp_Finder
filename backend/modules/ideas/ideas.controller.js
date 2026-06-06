const service = require('./ideas.service');

const sendSuccess = (res, statusCode, message, data, extra = {}) => {
  return res.status(statusCode).json({
    success: true,
    message,
    ...extra,
    data,
  });
};

const getAll = async (req, res, next) => {
  try {
    const data = await service.getAllIdeas(req.query.status);
    return sendSuccess(res, 200, 'Ideas fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const getById = async (req, res, next) => {
  try {
    const data = await service.getIdeaById(req.params.id);

    if (!data) {
      const err = new Error('Idea not found');
      err.statusCode = 404;
      throw err;
    }

    return sendSuccess(res, 200, 'Idea fetched successfully', data);
  } catch (err) {
    return next(err);
  }
};

const getMy = async (req, res, next) => {
  try {
    const data = await service.getMyIdeas(req.user.studentId);
    return sendSuccess(res, 200, 'My ideas fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const create = async (req, res, next) => {
  try {
    const data = await service.createIdea(req.body, req.user.studentId);
    return sendSuccess(res, 201, 'Idea created successfully', data);
  } catch (err) {
    return next(err);
  }
};

const update = async (req, res, next) => {
  try {
    const data = await service.updateIdea(req.params.id, req.body, req.user.studentId);
    return sendSuccess(res, 200, 'Idea updated successfully', data);
  } catch (err) {
    return next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    await service.deleteIdea(req.params.id, req.user.studentId);
    return sendSuccess(res, 200, 'Idea deleted successfully', null);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getAll,
  getById,
  getMy,
  create,
  update,
  remove,
};
