// File: src/services/penggunaService.js
const Pengguna = require('../models/penggunamodel'); 
const { Op } = require('sequelize');

const penggunaService = {
    getAllUsers: async (page = 1, limit = 15, search = '') => {
        try {
            // Hitung nilai offset (titik mulai data ditarik)
            const offset = (page - 1) * limit;
            
            // Konfigurasi dasar kueri Sequelize
            const queryOptions = {
                limit: parseInt(limit),
                offset: parseInt(offset),
                attributes: { exclude: ['kata_sandi'] }, // PROTEKSI: Jangan bocorkan password ke client!
                order: [['nama_lengkap', 'ASC']]
            };

            // Jika Admin mengisi kolom pencarian nama/email
            if (search) {
                queryOptions.where = {
                    [Op.or]: [
                        { nama_lengkap: { [Op.like]: `%${search}%` } },
                        { email: { [Op.like]: `%${search}%` } }
                    ]
                };
            }

            // findAndCountAll mengembalikan { count: total_data, rows: data_tabel }
            const result = await Pengguna.findAndCountAll(queryOptions);
            return result;
        } catch (error) {
            throw new Error('Gagal mengambil daftar pengguna: ' + error.message);
        }
    },

    // [USER] Mengambil data profil sendiri
    getUserById: async (id) => {
        try {
            const user = await Pengguna.findByPk(id, {
                attributes: { exclude: ['kata_sandi'] } // Amankan password
            });
            if (!user) throw new Error('Pengguna tidak ditemukan.');

            const timeUtil = require('../utils/timeUtil');
            const userData = user.toJSON();
            userData.jadwal_microbreak = timeUtil.calculateMicrobreaks(
                userData.jam_masuk_kerja,
                userData.jam_keluar_kerja,
                userData.jam_mulai_istirahat,
                userData.jam_selesai_istirahat
            );

            return userData;
        } catch (error) {
            throw new Error('Gagal mengambil profil: ' + error.message);
        }
    },

    // [USER] Memperbarui biodata dan jam kerja
    updateUser: async (id, data) => {
        try {
            const user = await Pengguna.findByPk(id);
            if (!user) throw new Error('Pengguna tidak ditemukan.');

            // Lakukan update data
            await user.update({
                nama_lengkap: data.nama_lengkap || user.nama_lengkap,
                jam_masuk_kerja: data.jam_masuk_kerja || user.jam_masuk_kerja,
                jam_keluar_kerja: data.jam_keluar_kerja || user.jam_keluar_kerja,
                jam_mulai_istirahat: data.jam_mulai_istirahat || user.jam_mulai_istirahat,
                jam_selesai_istirahat: data.jam_selesai_istirahat || user.jam_selesai_istirahat
            });

            return await penggunaService.getUserById(id); // Kembalikan data terbaru
        } catch (error) {
            throw new Error('Gagal memperbarui profil: ' + error.message);
        }
    }
};

module.exports = penggunaService;