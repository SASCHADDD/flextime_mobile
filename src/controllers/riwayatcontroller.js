// File: src/controllers/riwayatController.js
const riwayatService = require('../services/riwayatService');

const riwayatController = {
    // [USER] Fungsi untuk menyimpan riwayat setelah sesi latihan selesai
    create: async (req, res) => {
        try {
            // Kita rakit data yang akan disimpan
            const dataInput = {
                pengguna_id: req.user.id, // Diambil dari JWT Middleware agar aman dari manipulasi
                gerakan_id: req.body.gerakan_id,
                sesi: req.body.sesi,      // Wajib diisi: 'Pagi', 'Siang', atau 'Sore'
                status_kepatuhan: req.body.status_kepatuhan || 'Melakukan',
                durasi_detik: req.body.durasi_detik || 0
            };

            const riwayatBaru = await riwayatService.createRiwayat(dataInput);

            res.status(201).json({
                success: true,
                message: 'Riwayat latihan berhasil disimpan.',
                data: riwayatBaru
            });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    // [ADMIN] Fungsi untuk melihat laporan riwayat pengguna lain
    getByPengguna: async (req, res) => {
        try {
            const idPengguna = req.params.id; // Ambil ID dari URL (/pengguna/1)
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 15;

            // Tarik data dari Service
            const { count, rows } = await riwayatService.getRiwayatByPengguna(idPengguna, page, limit);
            const totalPages = Math.ceil(count / limit);

            res.status(200).json({
                success: true,
                message: 'Riwayat kepatuhan berhasil ditarik.',
                pagination: {
                    total_items: count,
                    total_pages: totalPages,
                    current_page: page,
                    limit: limit
                },
                data: rows
            });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }
};

module.exports = riwayatController;