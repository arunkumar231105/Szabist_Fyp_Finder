const jwt = require('jsonwebtoken');

const protect = (req, res, next) => {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'No token provided',
      data: null,
    });
  }

  const token = header.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = {
      userId: decoded.userId,
      studentId: decoded.studentId,
      email: decoded.email,
      role: decoded.role,
    };

    return next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
      data: null,
    });
  }
};

module.exports = {
  protect,
};
