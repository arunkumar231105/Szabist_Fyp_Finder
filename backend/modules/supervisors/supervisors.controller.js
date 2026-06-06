const service = require('./supervisors.service');

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
    const data = await service.getAllSupervisors(req.query.available);
    return sendSuccess(res, 200, 'Supervisors fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const getById = async (req, res, next) => {
  try {
    const data = await service.getSupervisorById(req.params.id);

    if (!data) {
      const err = new Error('Supervisor not found');
      err.statusCode = 404;
      throw err;
    }

    return sendSuccess(res, 200, 'Supervisor fetched successfully', data);
  } catch (err) {
    return next(err);
  }
};

const create = async (req, res, next) => {
  try {
    const data = await service.createSupervisor(req.body);
    return sendSuccess(res, 201, 'Supervisor created successfully', data);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      err.statusCode = 409;
      err.message = 'Email already exists';
    }

    return next(err);
  }
};

const update = async (req, res, next) => {
  try {
    const data = await service.updateSupervisor(req.params.id, req.body);

    if (!data) {
      const err = new Error('Supervisor not found');
      err.statusCode = 404;
      throw err;
    }

    return sendSuccess(res, 200, 'Supervisor updated successfully', data);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      err.statusCode = 409;
      err.message = 'Email already exists';
    }

    return next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    const deleted = await service.deleteSupervisor(req.params.id);

    if (!deleted) {
      const err = new Error('Supervisor not found');
      err.statusCode = 404;
      throw err;
    }

    return sendSuccess(res, 200, 'Supervisor deleted successfully', null);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getAll,
  getById,
  create,
  update,
  remove,
};
