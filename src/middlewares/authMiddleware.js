const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = {
    // 1. Middleware untuk mengecek apakah user memiliki token valid
    verifyToken: (req, res, next) => {
        // Ambil header otorisasi (Biasanya formatnya: "Bearer <token>")
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) {
            return res.status(401).json({ 
                success: false, 
                message: 'Akses ditolak. Token otorisasi tidak ditemukan.' 
            });
        }

        try {
            // Verifikasi token menggunakan rahasia dari .env
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            
            // Simpan data payload token (seperti id dan peran) ke object req
            // Agar bisa diakses oleh Controller nanti
            req.pengguna = decoded; 
            
            // Loloskan ke Controller selanjutnya
            next(); 
        } catch (error) {
            return res.status(403).json({ 
                success: false, 
                message: 'Akses ditolak. Token tidak valid atau sudah kedaluwarsa.' 
            });
        }
    },

    // 2. Middleware khusus untuk membatasi akses Admin (Sesuai SRS RBAC)
    verifyAdmin: (req, res, next) => {
        if (req.pengguna && req.pengguna.peran === 'admin') {
            next(); // Loloskan jika dia admin
        } else {
            return res.status(403).json({ 
                success: false, 
                message: 'Akses ditolak. Endpoint ini hanya untuk Administrator.' 
            });
        }
    }
};

module.exports = authMiddleware;