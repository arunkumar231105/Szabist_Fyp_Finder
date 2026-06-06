const db = require('../../config/db');

const toArr = (value) => (value ? value.split(',').map((item) => item.trim()).filter(Boolean) : []);
const toStr = (value) => (Array.isArray(value) ? value.join(',') : value || '');

const fmt = (row) => ({
  id: row.id,
  name: row.name,
  email: row.email,
  department: row.department,
  designation: row.designation,
  specialization: toArr(row.specialization),
  availableSlots: row.available_slots,
  isAvailable: row.is_available === 1,
  createdAt: row.created_at,
});

const getAllSupervisors = async (isAvailable) => {
  let sql = 'SELECT * FROM supervisors WHERE 1=1';
  const params = [];

  if (isAvailable !== undefined) {
    sql += ' AND is_available = ?';
    params.push(isAvailable === true || isAvailable === 'true' ? 1 : 0);
  }

  sql += ' ORDER BY name ASC';

  const [rows] = await db.query(sql, params);
  return rows.map(fmt);
};

const getSupervisorById = async (id) => {
  const [rows] = await db.query('SELECT * FROM supervisors WHERE id = ?', [id]);
  return rows.length ? fmt(rows[0]) : null;
};

const createSupervisor = async (data) => {
  const [result] = await db.query(
    `INSERT INTO supervisors (
      name, email, department, designation, specialization, available_slots, is_available
    ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      data.name,
      data.email,
      data.department,
      data.designation || '',
      toStr(data.specialization),
      data.availableSlots || 0,
      data.isAvailable !== false ? 1 : 0,
    ]
  );

  return getSupervisorById(result.insertId);
};

const updateSupervisor = async (id, data) => {
  const [result] = await db.query(
    `UPDATE supervisors SET
      name = ?,
      email = ?,
      department = ?,
      designation = ?,
      specialization = ?,
      available_slots = ?,
      is_available = ?
    WHERE id = ?`,
    [
      data.name,
      data.email,
      data.department,
      data.designation || '',
      toStr(data.specialization),
      data.availableSlots || 0,
      data.isAvailable !== false ? 1 : 0,
      id,
    ]
  );

  return result.affectedRows ? getSupervisorById(id) : null;
};

const deleteSupervisor = async (id) => {
  const [result] = await db.query('DELETE FROM supervisors WHERE id = ?', [id]);
  return result.affectedRows > 0;
};

module.exports = {
  getAllSupervisors,
  getSupervisorById,
  createSupervisor,
  updateSupervisor,
  deleteSupervisor,
};
