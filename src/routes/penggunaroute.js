// File: src/routes/penggunaRoute.js
const express = require('express');
const router = express.Router();
const penggunaController = require('../controllers/penggunaController');
const { verifyToken, verifyAdmin } = require('../middlewares/authMiddleware');

// Rute User (Melihat dan Memperbarui Profil Sendiri)
router.get('/me', verifyToken, penggunaController.getMe);
router.put('/me', verifyToken, penggunaController.updateMe);

// Kunci rute secara ketat menggunakan middleware otorisasi berbasis peran (RBAC)
router.get('/', verifyToken, verifyAdmin, penggunaController.getAll);

module.exports = router;