const { error } = require('../utils/response');

const validate = (requiredFields = []) => {
  return (req, res, next) => {
    const missingFields = requiredFields.filter((field) => {
      return req.body[field] === undefined || req.body[field] === null || req.body[field] === '';
    });

    if (missingFields.length > 0) {
      return error(res, `Missing required fields: ${missingFields.join(', ')}`, 400);
    }

    return next();
  };
};

module.exports = validate;
