const db = require('../../config/db');

const toArr = (value) => (value ? value.split(',').map((item) => item.trim()).filter(Boolean) : []);
const toStr = (value) => (Array.isArray(value) ? value.join(',') : value || '');

const createError = (statusCode, message) => {
  const err = new Error(message);
  err.statusCode = statusCode;
  return err;
};

const validateStudentData = (data, { requireAll = true } = {}) => {
  const requiredFields = ['name', 'email', 'registrationId', 'department'];

  if (requireAll) {
    const missingFields = requiredFields.filter((field) => !data[field]);

    if (missingFields.length) {
      throw createError(400, `Missing required fields: ${missingFields.join(', ')}`);
    }
  }

  if (data.email && !data.email.endsWith('@szabist.pk')) {
    throw createError(400, 'Only @szabist.pk emails allowed');
  }

  if (
    data.completionPercentage !== undefined &&
    (Number(data.completionPercentage) < 0 || Number(data.completionPercentage) > 100)
  ) {
    throw createError(400, 'completionPercentage must be between 0 and 100');
  }
};

const fmt = (row) => ({
  id: row.id,
  userId: row.user_id,
  name: row.name,
  email: row.email,
  registrationId: row.registration_id,
  department: row.department,
  section: row.section,
  batch: row.batch,
  skills: toArr(row.skills),
  technologies: toArr(row.technologies),
  interests: toArr(row.interests),
  bio: row.bio,
  githubUrl: row.github_url,
  linkedinUrl: row.linkedin_url,
  completionPercentage: row.completion_percentage,
  isLocked: row.is_locked === 1,
  isProfilePublic: row.is_profile_public === 1,
  createdAt: row.created_at,
});

const getAllStudents = async (filters = {}) => {
  let sql = 'SELECT * FROM students WHERE is_profile_public = 1';
  const params = [];

  if (filters.department) {
    sql += ' AND department = ?';
    params.push(filters.department);
  }

  if (filters.batch) {
    sql += ' AND batch = ?';
    params.push(filters.batch);
  }

  sql += ' ORDER BY name ASC';

  const [rows] = await db.query(sql, params);
  return rows.map(fmt);
};

const getStudentById = async (id) => {
  const [rows] = await db.query('SELECT * FROM students WHERE id = ?', [id]);
  return rows.length ? fmt(rows[0]) : null;
};

const getMyProfile = async (studentId) => {
  return getStudentById(studentId);
};

const createStudent = async (data) => {
  validateStudentData(data);

  const [result] = await db.query(
    `INSERT INTO students (
      user_id, name, email, registration_id, department, section, batch,
      skills, technologies, interests, bio, github_url, linkedin_url,
      completion_percentage, is_locked, is_profile_public
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.userId,
      data.name,
      data.email,
      data.registrationId,
      data.department,
      data.section || '',
      data.batch || '',
      toStr(data.skills),
      toStr(data.technologies),
      toStr(data.interests),
      data.bio || null,
      data.githubUrl || null,
      data.linkedinUrl || null,
      data.completionPercentage || 0,
      data.isLocked ? 1 : 0,
      data.isProfilePublic !== false ? 1 : 0,
    ]
  );

  return getStudentById(result.insertId);
};

const updateStudent = async (id, data) => {
  validateStudentData(data);

  const [result] = await db.query(
    `UPDATE students SET
      name = ?,
      email = ?,
      registration_id = ?,
      department = ?,
      section = ?,
      batch = ?,
      skills = ?,
      technologies = ?,
      interests = ?,
      bio = ?,
      github_url = ?,
      linkedin_url = ?,
      completion_percentage = ?,
      is_locked = ?,
      is_profile_public = ?
    WHERE id = ?`,
    [
      data.name,
      data.email,
      data.registrationId,
      data.department,
      data.section || '',
      data.batch || '',
      toStr(data.skills),
      toStr(data.technologies),
      toStr(data.interests),
      data.bio || null,
      data.githubUrl || null,
      data.linkedinUrl || null,
      data.completionPercentage || 0,
      data.isLocked ? 1 : 0,
      data.isProfilePublic !== false ? 1 : 0,
      id,
    ]
  );

  return result.affectedRows ? getStudentById(id) : null;
};

const deleteStudent = async (id) => {
  const [result] = await db.query('DELETE FROM students WHERE id = ?', [id]);
  return result.affectedRows > 0;
};

module.exports = {
  getAllStudents,
  getStudentById,
  getMyProfile,
  createStudent,
  updateStudent,
  deleteStudent,
};
