const express = require('express');
const cors    = require('cors');
require('dotenv').config();

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Module 1 — Students
app.use('/api/students',    require('./routes/students'));
// Module 2 — Ideas
app.use('/api/ideas',       require('./routes/ideas'));
// Module 3 — Requests
app.use('/api/requests',    require('./routes/requests'));
// Module 4 — Supervisors
app.use('/api/supervisors', require('./routes/supervisors'));

app.get('/', (req, res) => {
  res.json({
    message: 'SZABIST FYP Finder API is running!',
    routes: {
      students:    `/api/students`,
      ideas:       `/api/ideas`,
      requests:    `/api/requests`,
      supervisors: `/api/supervisors`,
    },
  });
});

app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route "${req.path}" not found` });
});

app.listen(PORT, () => {
  console.log('==============================================');
  console.log('  SZABIST FYP Finder Backend — Running!');
  console.log(`  Students:    http://localhost:${PORT}/api/students`);
  console.log(`  Ideas:       http://localhost:${PORT}/api/ideas`);
  console.log(`  Requests:    http://localhost:${PORT}/api/requests`);
  console.log(`  Supervisors: http://localhost:${PORT}/api/supervisors`);
  console.log('==============================================');
});
