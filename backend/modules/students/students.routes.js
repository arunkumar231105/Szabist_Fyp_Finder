const router = require('express').Router();
const ctrl = require('./students.controller');
const validate = require('../../middleware/validate');
const { protect } = require('../../middleware/auth');

router.get('/', protect, ctrl.getAll);
router.get('/me', protect, ctrl.getMe);
router.get('/:id', protect, ctrl.getById);
router.post('/', protect, validate(['name', 'email', 'registrationId', 'department']), ctrl.create);
router.put('/:id', protect, validate(['name', 'email', 'registrationId', 'department']), ctrl.update);
router.delete('/:id', protect, ctrl.remove);

module.exports = router;
