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
                attributes: { exclude: ['password'] }, // PROTEKSI: Jangan bocorkan password ke client!
                order: [['username', 'ASC']]
            };

            // Jika Admin mengisi kolom pencarian nama/username
            if (search) {
                queryOptions.where = {
                    username: {
                        [Op.like]: `%${search}%`
                    },
                    email: {
                        [Op.like]: `%${search}%`    
                    }
                };
            }

            // findAndCountAll mengembalikan { count: total_data, rows: data_tabel }
            const result = await Pengguna.findAndCountAll(queryOptions);
            return result;
        } catch (error) {
            throw new Error('Gagal mengambil daftar pengguna: ' + error.message);
        }
    }
};

module.exports = penggunaService;