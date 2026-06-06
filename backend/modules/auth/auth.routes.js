const express = require('express');
const authController = require('./auth.controller');
const validate = require('../../middleware/validate');

const router = express.Router();

router.post(
  '/register',
  validate(['name', 'email', 'password', 'registrationId', 'department']),
  authController.register
);
router.post('/login', validate(['email', 'password']), authController.login);

module.exports = router;
