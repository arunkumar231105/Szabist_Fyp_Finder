const authService = require('./auth.service');
const { success } = require('../../utils/response');

const register = async (req, res, next) => {
  try {
    const data = await authService.register(req.body);
    return success(res, 'Registration successful', data, 201);
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') {
      err.statusCode = 409;
      err.message = 'Email or registration ID already exists';
    }

    return next(err);
  }
};

const login = async (req, res, next) => {
  try {
    const data = await authService.login(req.body);
    return success(res, 'Login successful', data);
  } catch (err) {
    return next(err);
  }
};

module.exports = {
  register,
  login,
};
