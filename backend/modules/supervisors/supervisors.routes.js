const router = require('express').Router();
const ctrl = require('./supervisors.controller');
const validate = require('../../middleware/validate');
const { protect } = require('../../middleware/auth');

const adminOnly = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({
      success: false,
      message: 'Admin access required',
      data: null,
    });
  }

  return next();
};

router.get('/', ctrl.getAll);
router.get('/:id', ctrl.getById);
router.post('/', protect, adminOnly, validate(['name', 'email', 'department']), ctrl.create);
router.put('/:id', protect, adminOnly, validate(['name', 'email', 'department']), ctrl.update);
router.delete('/:id', protect, adminOnly, ctrl.remove);

module.exports = router;
