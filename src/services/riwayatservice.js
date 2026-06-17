// File: src/services/riwayatService.js
const RiwayatKepatuhan = require('../models/riwayatmodel');
const Gerakan = require('../models/GerakanModel'); // Sesuaikan huruf besar/kecil dengan nama file Anda

const riwayatService = {
    // [USER] Menyimpan riwayat baru ke MySQL
    createRiwayat: async (data) => {
        try {
            // Validasi: Cek apakah sesi untuk tanggal ini sudah tercatat sebelumnya
            const existing = await RiwayatKepatuhan.findOne({
                where: {
                    pengguna_id: data.pengguna_id,
                    tanggal: data.tanggal,
                    sesi: data.sesi
                }
            });

            if (existing) {
                // Jika sudah ada, lempar error tanpa stacktrace berlebih
                const err = new Error(`Riwayat untuk sesi ${data.sesi} pada hari ini sudah tersimpan.`);
                err.isDuplicate = true;
                throw err;
            }

            return await RiwayatKepatuhan.create(data);
        } catch (error) {
            if (error.isDuplicate) {
                throw error;
            }
            throw new Error('Gagal mencatat riwayat latihan: ' + error.message);
        }
    },

    // [USER] Menarik riwayat milik sendiri
    getRiwayatKu: async (idPengguna) => {
        try {
            return await RiwayatKepatuhan.findAll({
                where: { pengguna_id: idPengguna },
                order: [['dibuat_pada', 'DESC']]
            });
        } catch (error) {
            throw new Error('Gagal mengambil riwayat kepatuhan: ' + error.message);
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
                order: [['dibuat_pada', 'DESC']] // Urutkan dari sesi latihan yang paling baru
            });
        } catch (error) {
            throw new Error('Gagal mengambil riwayat kepatuhan: ' + error.message);
        }
    }
};

module.exports = riwayatService;