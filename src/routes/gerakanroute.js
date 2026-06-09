// File: src/routes/gerakanRoutes.js
const express = require('express');
const router = express.Router();
const gerakanController = require('../controllers/gerakanController');
const { verifyToken, verifyAdmin } = require('../middlewares/authMiddleware');
const upload = require('../middlewares/uploadMiddleware'); 

// Semua rute wajib menggunakan token (Hanya yang sudah login yang bisa akses)
router.use(verifyToken);

// RUTE UMUM (Bisa diakses User & Admin)
router.get('/', gerakanController.getAll);
router.get('/:id', gerakanController.getById);

// RUTE ADMIN (Dicegat oleh verifyAdmin)
router.post('/', verifyAdmin, upload.single('gambar'), gerakanController.create);
router.put('/:id', verifyAdmin, upload.single('gambar'), gerakanController.update);
router.delete('/:id', verifyAdmin, gerakanController.delete);

module.exports = router;