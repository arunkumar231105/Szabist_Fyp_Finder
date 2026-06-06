const db = require('../../config/db');

const VALID_STATUSES = ['open', 'closed', 'archived'];

const toArr = (value) => (value ? value.split(',').map((item) => item.trim()).filter(Boolean) : []);
const toStr = (value) => (Array.isArray(value) ? value.join(',') : value || '');

const createError = (statusCode, message) => {
  const err = new Error(message);
  err.statusCode = statusCode;
  return err;
};

const validateStatus = (status) => {
  if (status && !VALID_STATUSES.includes(status)) {
    throw createError(400, 'Invalid idea status');
  }
};

const fmt = (row) => ({
  id: row.id,
  ownerName: row.owner_name,
  ownerId: row.owner_id,
  ownerDept: row.owner_dept,
  title: row.title,
  description: row.description,
  technologiesRequired: toArr(row.technologies_required),
  skillsRequired: toArr(row.skills_required),
  status: row.status,
  createdAt: row.created_at,
});

const getAllIdeas = async (status) => {
  validateStatus(status);

  let sql = 'SELECT * FROM ideas WHERE 1=1';
  const params = [];

  if (status) {
    sql += ' AND status = ?';
    params.push(status);
  }

  sql += ' ORDER BY created_at DESC';

  const [rows] = await db.query(sql, params);
  return rows.map(fmt);
};

const getIdeaById = async (id) => {
  const [rows] = await db.query('SELECT * FROM ideas WHERE id = ?', [id]);
  return rows.length ? fmt(rows[0]) : null;
};

const getMyIdeas = async (studentId) => {
  const [rows] = await db.query(
    'SELECT * FROM ideas WHERE owner_id = ? ORDER BY created_at DESC',
    [studentId]
  );
  return rows.map(fmt);
};

const getStudentSummary = async (studentId) => {
  const [rows] = await db.query(
    'SELECT name, department FROM students WHERE id = ?',
    [studentId]
  );

  if (!rows.length) {
    throw createError(404, 'Student profile not found');
  }

  return rows[0];
};

const createIdea = async (data, studentId) => {
  validateStatus(data.status || 'open');

  const student = await getStudentSummary(studentId);

  const [result] = await db.query(
    `INSERT INTO ideas (
      owner_name, owner_id, owner_dept, title, description,
      technologies_required, skills_required, status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      student.name,
      studentId,
      student.department,
      data.title,
      data.description,
      toStr(data.technologiesRequired),
      toStr(data.skillsRequired),
      data.status || 'open',
    ]
  );

  return getIdeaById(result.insertId);
};

const assertIdeaOwner = async (id, studentId) => {
  const [rows] = await db.query('SELECT owner_id FROM ideas WHERE id = ?', [id]);

  if (!rows.length) {
    throw createError(404, 'Idea not found');
  }

  if (rows[0].owner_id !== studentId) {
    throw createError(403, 'Not authorized to edit this idea');
  }
};

const updateIdea = async (id, data, studentId) => {
  validateStatus(data.status || 'open');
  await assertIdeaOwner(id, studentId);

  await db.query(
    `UPDATE ideas SET
      title = ?,
      description = ?,
      technologies_required = ?,
      skills_required = ?,
      status = ?
    WHERE id = ?`,
    [
      data.title,
      data.description,
      toStr(data.technologiesRequired),
      toStr(data.skillsRequired),
      data.status || 'open',
      id,
    ]
  );

  return getIdeaById(id);
};

const deleteIdea = async (id, studentId) => {
  await assertIdeaOwner(id, studentId);

  const [result] = await db.query('DELETE FROM ideas WHERE id = ?', [id]);
  return result.affectedRows > 0;
};

module.exports = {
  getAllIdeas,
  getIdeaById,
  getMyIdeas,
  createIdea,
  updateIdea,
  deleteIdea,
};
