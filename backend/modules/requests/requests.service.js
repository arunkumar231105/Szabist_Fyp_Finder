const db = require('../../config/db');

const fmt = (row) => ({
  id: row.id,
  senderId: row.sender_id,
  receiverId: row.receiver_id,
  senderName: row.sender_name,
  senderDept: row.sender_dept,
  receiverName: row.receiver_name,
  message: row.message,
  status: row.status,
  createdAt: row.created_at,
});

const createError = (statusCode, message) => {
  const err = new Error(message);
  err.statusCode = statusCode;
  return err;
};

const getStudent = async (studentId) => {
  const [rows] = await db.query(
    'SELECT id, name, department, is_locked FROM students WHERE id = ?',
    [studentId]
  );

  if (!rows.length) {
    throw createError(404, 'Student not found');
  }

  return rows[0];
};

const getRequestRow = async (requestId, connection = db) => {
  const [rows] = await connection.query('SELECT * FROM requests WHERE id = ?', [requestId]);

  if (!rows.length) {
    throw createError(404, 'Request not found');
  }

  return rows[0];
};

const getIncoming = async (studentId) => {
  const [rows] = await db.query(
    'SELECT * FROM requests WHERE receiver_id = ? ORDER BY created_at DESC',
    [studentId]
  );
  return rows.map(fmt);
};

const getOutgoing = async (studentId) => {
  const [rows] = await db.query(
    'SELECT * FROM requests WHERE sender_id = ? ORDER BY created_at DESC',
    [studentId]
  );
  return rows.map(fmt);
};

const ensureNoActiveRequest = async (studentId, receiverId) => {
  const [rows] = await db.query(
    `SELECT id FROM requests
     WHERE status IN ('pending', 'accepted')
     AND (sender_id IN (?, ?) OR receiver_id IN (?, ?))`,
    [studentId, receiverId, studentId, receiverId]
  );

  if (rows.length) {
    throw createError(400, 'Student already has a pending or accepted request');
  }
};

const sendRequest = async (data, studentId) => {
  const receiverId = Number(data.receiverId);

  if (!receiverId) {
    throw createError(400, 'receiverId is required');
  }

  if (receiverId === Number(studentId)) {
    throw createError(400, 'You cannot send a request to yourself');
  }

  await ensureNoActiveRequest(studentId, receiverId);

  const sender = await getStudent(studentId);
  const receiver = await getStudent(receiverId);

  const [result] = await db.query(
    `INSERT INTO requests (
      sender_id, receiver_id, sender_name, sender_dept, receiver_name, message, status
    ) VALUES (?, ?, ?, ?, ?, ?, 'pending')`,
    [
      studentId,
      receiverId,
      sender.name,
      sender.department,
      receiver.name,
      data.message || '',
    ]
  );

  const row = await getRequestRow(result.insertId);
  return fmt(row);
};

const acceptRequest = async (requestId, studentId) => {
  const connection = await db.getConnection();

  try {
    await connection.beginTransaction();

    const request = await getRequestRow(requestId, connection);

    if (request.receiver_id !== Number(studentId)) {
      throw createError(403, 'Only receiver can accept this request');
    }

    if (request.status !== 'pending') {
      throw createError(400, 'Only pending requests can be accepted');
    }

    await connection.query('UPDATE requests SET status = ? WHERE id = ?', ['accepted', requestId]);

    await connection.query(
      'UPDATE students SET is_locked = 1 WHERE id IN (?, ?)',
      [request.sender_id, request.receiver_id]
    );

    await connection.query(
      `UPDATE requests SET status = 'rejected'
       WHERE id != ? AND status = 'pending'
       AND (sender_id IN (?, ?) OR receiver_id IN (?, ?))`,
      [requestId, request.sender_id, request.receiver_id, request.sender_id, request.receiver_id]
    );

    await connection.commit();

    const accepted = await getRequestRow(requestId);
    return fmt(accepted);
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
};

const rejectRequest = async (requestId, studentId) => {
  const request = await getRequestRow(requestId);

  if (request.receiver_id !== Number(studentId)) {
    throw createError(403, 'Only receiver can reject this request');
  }

  if (request.status !== 'pending') {
    throw createError(400, 'Only pending requests can be rejected');
  }

  await db.query('UPDATE requests SET status = ? WHERE id = ?', ['rejected', requestId]);

  const rejected = await getRequestRow(requestId);
  return fmt(rejected);
};

const cancelRequest = async (requestId, studentId) => {
  const request = await getRequestRow(requestId);

  if (request.sender_id !== Number(studentId)) {
    throw createError(403, 'Only sender can cancel this request');
  }

  if (request.status !== 'pending') {
    throw createError(400, 'Only pending requests can be cancelled');
  }

  const [result] = await db.query('DELETE FROM requests WHERE id = ?', [requestId]);
  return result.affectedRows > 0;
};

module.exports = {
  getIncoming,
  getOutgoing,
  sendRequest,
  acceptRequest,
  rejectRequest,
  cancelRequest,
};
