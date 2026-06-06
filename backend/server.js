const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./modules/auth/auth.routes');
const studentsRoutes = require('./modules/students/students.routes');
const ideasRoutes = require('./modules/ideas/ideas.routes');
const requestsRoutes = require('./modules/requests/requests.routes');
const supervisorsRoutes = require('./modules/supervisors/supervisors.routes');
const errorHandler = require('./middleware/errorHandler');
const { success, error } = require('./utils/response');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  return success(res, 'SZABIST FYP Finder API is running', {
    routes: {
      auth: '/api/auth',
      students: '/api/students',
      ideas: '/api/ideas',
      requests: '/api/requests',
      supervisors: '/api/supervisors',
    },
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/students', studentsRoutes);
app.use('/api/ideas', ideasRoutes);
app.use('/api/requests', requestsRoutes);
app.use('/api/supervisors', supervisorsRoutes);

app.use((req, res) => {
  return error(res, `Route "${req.originalUrl}" not found`, 404);
});

app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`SZABIST FYP Finder API running on http://localhost:${PORT}`);
});

module.exports = app;
