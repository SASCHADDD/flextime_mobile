// File: src/services/riwayatService.js
const RiwayatKepatuhan = require('../models/riwayatmodel');
const Gerakan = require('../models/GerakanModel'); // Sesuaikan huruf besar/kecil dengan nama file Anda

const riwayatService = {
    // [USER] Menyimpan riwayat baru ke MySQL
    createRiwayat: async (data) => {
        try {
            return await RiwayatKepatuhan.create(data);
        } catch (error) {
            throw new Error('Gagal mencatat riwayat latihan: ' + error.message);
        }
    },

    // [ADMIN] Menarik riwayat berdasarkan ID dengan Pagination
    getRiwayatByPengguna: async (idPengguna, page = 1, limit = 15) => {
        try {
            const offset = (page - 1) * limit;

            return await RiwayatKepatuhan.findAndCountAll({
                where: { pengguna_id: idPengguna },
                limit: parseInt(limit),
                offset: parseInt(offset),
                order: [['dibuat_pada', 'DESC']], // Urutkan dari sesi latihan yang paling baru
                include: [
                    {
                        model: Gerakan,
                        as: 'gerakan',
                        attributes: ['nama_gerakan', 'gambar'] // Hanya ambil kolom yang diperlukan
                    }
                ]
            });
        } catch (error) {
            throw new Error('Gagal mengambil riwayat kepatuhan: ' + error.message);
        }
    }
};

module.exports = riwayatService;