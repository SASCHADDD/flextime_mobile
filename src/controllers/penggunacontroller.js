// File: src/controllers/penggunaController.js
const penggunaService = require('../services/penggunaservice');

const penggunaController = {
    getAll: async (req, res) => {
        try {
            // Ambil parameter kueri dari URL (default: page=1, limit=15 sesuai batas SRS)
            const page = parseInt(req.query.page) || 1;
            const limit = parseInt(req.query.limit) || 15;
            const search = req.query.search || '';

            // Panggil fungsi dapur service
            const { count, rows } = await penggunaService.getAllUsers(page, limit, search);

            // Hitung total halaman yang tersedia
            const totalPages = Math.ceil(count / limit);

            res.status(200).json({
                success: true,
                message: 'Daftar pengguna berhasil diambil.',
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

module.exports = penggunaController;