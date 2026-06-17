// File: src/controllers/riwayatController.js
const riwayatService = require('../services/riwayatService');

const riwayatController = {
    // [USER] Fungsi untuk menyimpan riwayat setelah sesi latihan selesai
    create: async (req, res) => {
        try {
            const validSesi = ['Pagi', 'Siang', 'Sore', 'Sesi 1', 'Sesi 2', 'Sesi 3'];
            if (!validSesi.includes(req.body.sesi)) {
                return res.status(400).json({ message: 'Sesi tidak valid.' });
            }

            const dataInput = {
                pengguna_id: req.pengguna.id, // Diambil dari JWT Middleware
                tanggal: req.body.tanggal || new Date().toISOString().split('T')[0],
                sesi: req.body.sesi,      // Wajib diisi: 'Pagi', 'Siang', atau 'Sore'
                status_kepatuhan: req.body.status_kepatuhan || 'Melakukan'
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

    // [USER] Menarik riwayat milik sendiri
    getMine: async (req, res) => {
        try {
            const idPengguna = req.pengguna.id;
            const rows = await riwayatService.getRiwayatKu(idPengguna);
            res.status(200).json({
                success: true,
                message: 'Riwayat kepatuhan berhasil ditarik.',
                data: rows
            });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
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