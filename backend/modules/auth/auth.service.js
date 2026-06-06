const db = require('../../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const createToken = (payload) => {
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

const register = async ({ name, email, password, registrationId, department, section, batch }) => {
  if (!email.endsWith('@szabist.pk')) {
    const err = new Error('Only @szabist.pk emails allowed');
    err.statusCode = 400;
    throw err;
  }

  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const passwordHash = await bcrypt.hash(password, 12);

    const [userResult] = await connection.query(
      'INSERT INTO users (email, password_hash) VALUES (?, ?)',
      [email, passwordHash]
    );

    const userId = userResult.insertId;

    const [studentResult] = await connection.query(
      `INSERT INTO students (
        user_id, name, email, registration_id, department, section, batch
      ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [userId, name, email, registrationId, department, section || '', batch || '']
    );

    const studentId = studentResult.insertId;
    const token = createToken({ userId, studentId, email, role: 'student' });

    await connection.commit();

    return {
      userId,
      studentId,
      token,
    };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

const login = async ({ email, password }) => {
  const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);

  if (!users.length) {
    const err = new Error('Invalid email or password');
    err.statusCode = 401;
    throw err;
  }

  const user = users[0];
  const match = await bcrypt.compare(password, user.password_hash);

  if (!match) {
    const err = new Error('Invalid email or password');
    err.statusCode = 401;
    throw err;
  }

  const [students] = await db.query('SELECT id, name FROM students WHERE user_id = ?', [user.id]);
  const student = students[0];

  if (!student) {
    const err = new Error('Student profile not found');
    err.statusCode = 404;
    throw err;
  }

  const token = createToken({
    userId: user.id,
    studentId: student.id,
    email: user.email,
    role: user.role,
  });

  return {
    token,
    studentId: student.id,
    name: student.name,
  };
};

module.exports = {
  register,
  login,
};
