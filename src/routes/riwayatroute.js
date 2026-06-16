// File: src/routes/riwayatRoute.js
const express = require('express');
const router = express.Router();
const riwayatController = require('../controllers/riwayatController');
const { verifyToken, verifyAdmin } = require('../middlewares/authMiddleware');

// 1. Rute User (POST): Menyimpan riwayat
// Wajib pakai verifyToken agar req.user.id di Controller terbaca
router.post('/', verifyToken, riwayatController.create);

// 2. Rute User (GET): Mengambil riwayat sendiri
router.get('/', verifyToken, riwayatController.getMine);

// 2. Rute Admin (GET): Melihat laporan riwayat pengguna tertentu
// Dijaga super ketat oleh verifyAdmin
router.get('/pengguna/:id', verifyToken, verifyAdmin, riwayatController.getByPengguna);

module.exports = router;