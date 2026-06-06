require('dotenv').config();

const bcrypt = require('bcryptjs');
const db = require('../config/db');

const DEFAULT_PASSWORD = process.env.SEED_USER_PASSWORD || 'mypassword123';

const hasTable = async (tableName) => {
  const [rows] = await db.query(
    `SELECT COUNT(*) AS count
     FROM information_schema.tables
     WHERE table_schema = DATABASE() AND table_name = ?`,
    [tableName]
  );
  return rows[0].count > 0;
};

const hasColumn = async (tableName, columnName) => {
  const [rows] = await db.query(
    `SELECT COUNT(*) AS count
     FROM information_schema.columns
     WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ?`,
    [tableName, columnName]
  );
  return rows[0].count > 0;
};

const hasIndex = async (tableName, indexName) => {
  const [rows] = await db.query(
    `SELECT COUNT(*) AS count
     FROM information_schema.statistics
     WHERE table_schema = DATABASE() AND table_name = ? AND index_name = ?`,
    [tableName, indexName]
  );
  return rows[0].count > 0;
};

const hasConstraint = async (constraintName) => {
  const [rows] = await db.query(
    `SELECT COUNT(*) AS count
     FROM information_schema.table_constraints
     WHERE table_schema = DATABASE() AND constraint_name = ?`,
    [constraintName]
  );
  return rows[0].count > 0;
};

const addIndex = async (tableName, indexName, columnsSql, unique = false) => {
  if (!(await hasIndex(tableName, indexName))) {
    await db.query(
      `CREATE ${unique ? 'UNIQUE ' : ''}INDEX ${indexName} ON ${tableName} (${columnsSql})`
    );
    console.log(`added index ${indexName}`);
  }
};

const addForeignKey = async (tableName, constraintName, fkSql) => {
  if (!(await hasConstraint(constraintName))) {
    await db.query(`ALTER TABLE ${tableName} ADD CONSTRAINT ${constraintName} ${fkSql}`);
    console.log(`added foreign key ${constraintName}`);
  }
};

const createUsersTable = async () => {
  if (!(await hasTable('users'))) {
    await db.query(
      `CREATE TABLE users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(150) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        role ENUM('student','admin') NOT NULL DEFAULT 'student',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`
    );
    console.log('created users table');
  }
};

const ensureStudentsUserId = async () => {
  if (!(await hasColumn('students', 'user_id'))) {
    await db.query('ALTER TABLE students ADD COLUMN user_id INT NULL AFTER id');
    console.log('added students.user_id');
  }

  await addIndex('students', 'idx_students_user_id_unique', 'user_id', true);
};

const ensureRequestIds = async () => {
  if (!(await hasColumn('requests', 'sender_id'))) {
    await db.query('ALTER TABLE requests ADD COLUMN sender_id INT NULL AFTER id');
    console.log('added requests.sender_id');
  }

  if (!(await hasColumn('requests', 'receiver_id'))) {
    await db.query('ALTER TABLE requests ADD COLUMN receiver_id INT NULL AFTER sender_id');
    console.log('added requests.receiver_id');
  }

  await db.query(
    `UPDATE requests r
     JOIN students s ON s.name = r.sender_name
     SET r.sender_id = s.id
     WHERE r.sender_id IS NULL`
  );

  await db.query(
    `UPDATE requests r
     JOIN students s ON s.name = r.receiver_name
     SET r.receiver_id = s.id
     WHERE r.receiver_id IS NULL`
  );

  const [missing] = await db.query(
    'SELECT id, sender_name, receiver_name FROM requests WHERE sender_id IS NULL OR receiver_id IS NULL'
  );

  if (missing.length) {
    console.warn('Some requests could not be linked to students:', missing);
  }

  await addIndex('requests', 'idx_requests_sender', 'sender_id');
  await addIndex('requests', 'idx_requests_receiver', 'receiver_id');
  await addIndex('requests', 'idx_requests_status', 'status');
  await addIndex('requests', 'idx_requests_receiver_status', 'receiver_id, status');
};

const ensureCommonIndexes = async () => {
  await addIndex('students', 'idx_students_department', 'department');
  await addIndex('students', 'idx_students_batch', 'batch');
  await addIndex('students', 'idx_students_dept_batch', 'department, batch');
  await addIndex('ideas', 'idx_ideas_status', 'status');
  await addIndex('ideas', 'idx_ideas_owner', 'owner_id');
  await addIndex('supervisors', 'idx_supervisors_available', 'is_available');
};

const backfillUsers = async () => {
  const passwordHash = await bcrypt.hash(DEFAULT_PASSWORD, 12);
  const [students] = await db.query(
    'SELECT id, email FROM students WHERE user_id IS NULL ORDER BY id'
  );

  for (const student of students) {
    await db.query(
      `INSERT INTO users (email, password_hash, role)
       VALUES (?, ?, 'student')
       ON DUPLICATE KEY UPDATE email = VALUES(email)`,
      [student.email, passwordHash]
    );

    const [users] = await db.query('SELECT id FROM users WHERE email = ?', [student.email]);
    await db.query('UPDATE students SET user_id = ? WHERE id = ?', [users[0].id, student.id]);
    console.log(`linked student ${student.id} to user ${users[0].id}`);
  }
};

const addForeignKeys = async () => {
  await addForeignKey(
    'students',
    'fk_students_user',
    'FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE'
  );

  await addForeignKey(
    'requests',
    'fk_requests_sender',
    'FOREIGN KEY (sender_id) REFERENCES students(id) ON DELETE CASCADE'
  );

  await addForeignKey(
    'requests',
    'fk_requests_receiver',
    'FOREIGN KEY (receiver_id) REFERENCES students(id) ON DELETE CASCADE'
  );

  await addForeignKey(
    'ideas',
    'fk_ideas_owner',
    'FOREIGN KEY (owner_id) REFERENCES students(id) ON DELETE CASCADE'
  );
};

const migrate = async () => {
  await createUsersTable();
  await ensureStudentsUserId();
  await ensureRequestIds();
  await ensureCommonIndexes();
  await backfillUsers();
  await addForeignKeys();
  console.log('migration complete');
};

migrate()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
