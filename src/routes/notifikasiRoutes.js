const express = require('express');
const router = express.Router();
const notifikasiController = require('../controllers/notifikasicontroller');
const authMiddleware = require('../middlewares/authmiddleware');

// [USER] Endpoint untuk notifikasi pengguna
router.get('/', authMiddleware.verifyToken, notifikasiController.getKu);
router.put('/read-all', authMiddleware.verifyToken, notifikasiController.readAll);
router.put('/:id/read', authMiddleware.verifyToken, notifikasiController.readOne);

// [SYSTEM/ADMIN] Endpoint untuk membuat notifikasi
router.post('/', authMiddleware.verifyToken, authMiddleware.verifyAdmin, notifikasiController.create);

module.exports = router;
