const router = require('express').Router();
const ctrl = require('./ideas.controller');
const validate = require('../../middleware/validate');
const { protect } = require('../../middleware/auth');

router.get('/', protect, ctrl.getAll);
router.get('/my', protect, ctrl.getMy);
router.get('/:id', protect, ctrl.getById);
router.post('/', protect, validate(['title', 'description']), ctrl.create);
router.put('/:id', protect, validate(['title', 'description']), ctrl.update);
router.delete('/:id', protect, ctrl.remove);

module.exports = router;
