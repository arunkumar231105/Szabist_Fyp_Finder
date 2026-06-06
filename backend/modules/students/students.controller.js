const service = require('./students.service');

const sendSuccess = (res, statusCode, message, data, extra = {}) => {
  return res.status(statusCode).json({
    success: true,
    message,
    ...extra,
    data,
  });
};

const sendNotFound = (res) => {
  return res.status(404).json({
    success: false,
    message: 'Student not found',
    data: null,
  });
};

const getAll = async (req, res, next) => {
  try {
    const data = await service.getAllStudents(req.query);
    return sendSuccess(res, 200, 'Students fetched successfully', data, { count: data.length });
  } catch (err) {
    return next(err);
  }
};

const getById = async (req, res, next) => {
  try {
    const data = await service.getStudentById(req.params.id);

    if (!data) {
      return sendNotFound(res);
    }

    return sendSuccess(res, 200, 'Student fetched successfully', data);
  } catch (err) {
    return next(err);
  }
};

const getMe = async (req, res, next) => {
  try {
    const data = await service.getMyProfile(req.user.studentId);

    if (!data) {
      return sendNotFound(res);
    }

    return sendSuccess(res, 200, 'Profile fetched successfully', data);
  } catch (err) {
    return next(err);
  }
};

const create = async (req, res, next) => {
  try {
    const payload = {
      ...req.body,
      userId: req.body.userId || req.user.userId,
    };

    const data = await service.createStudent(payload);
    return sendSuccess(res, 201, 'Student created successfully', data);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      err.statusCode = 409;
      err.message = 'Email, user ID, or registration ID already exists';
    }

    return next(err);
  }
};

const update = async (req, res, next) => {
  try {
    const requestedId = Number(req.params.id);

    if (req.user.studentId !== requestedId) {
      const err = new Error('You can update only your own profile');
      err.statusCode = 403;
      throw err;
    }

    const data = await service.updateStudent(req.params.id, req.body);

    if (!data) {
      return sendNotFound(res);
    }

    return sendSuccess(res, 200, 'Student updated successfully', data);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      err.statusCode = 409;
      err.message = 'Email or registration ID already exists';
    }

    return next(err);
  }
};

const remove = async (req, res, next) => {
  try {
    if (req.user.role !== 'admin') {
      const err = new Error('Admin access required');
      err.statusCode = 403;
      throw err;
    }

    const deleted = await service.deleteStudent(req.params.id);

    if (!deleted) {
      return sendNotFound(res);
    }

    return sendSuccess(res, 200, 'Student deleted successfully', null);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  getAll,
  getById,
  getMe,
  create,
  update,
  remove,
};
