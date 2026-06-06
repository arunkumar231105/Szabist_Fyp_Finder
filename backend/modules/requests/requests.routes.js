const router = require('express').Router();
const ctrl = require('./requests.controller');
const validate = require('../../middleware/validate');
const { protect } = require('../../middleware/auth');

router.get('/incoming', protect, ctrl.getIncoming);
router.get('/outgoing', protect, ctrl.getOutgoing);
router.post('/', protect, validate(['receiverId']), ctrl.send);
router.put('/:id', protect, validate(['status']), ctrl.update);
router.delete('/:id', protect, ctrl.remove);

module.exports = router;
