const express = require('express');
const router = express.Router();
const tipsController = require('../controllers/tipscontrolller');

router.get('/', tipsController.getAll);
router.get('/:id', tipsController.getById);

module.exports = router;