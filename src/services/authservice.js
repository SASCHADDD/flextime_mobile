// File: src/services/authService.js
const sequelize = require('../config/database'); // <-- WAJIB IMPORT INI UNTUK TCL
const Pengguna = require('../models/PenggunaModel'); 
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const authService = {
    registerPengguna: async (data) => {
        // 1. Validasi input dasar
        if (!data.nama_lengkap || !data.email || !data.kata_sandi) {
            throw new Error('Nama lengkap, email, dan kata sandi wajib diisi.');
        }

        // 2. Cek duplikasi email menggunakan metode bawaan Sequelize (.findOne)
        const existingUser = await Pengguna.findOne({ where: { email: data.email } });
        if (existingUser) {
            throw new Error('Email sudah terdaftar. Silakan gunakan email lain.');
        }

        // 3. Hash kata sandi
        const hashedPassword = await bcrypt.hash(data.kata_sandi, 10);

        // 4. Simpan Menggunakan TCL (Managed Transaction)
        try {
            // Dimulai dari sini: Mengaktifkan START TRANSACTION secara otomatis
            const userId = await sequelize.transaction(async (t) => {
                
                const newUser = await Pengguna.create({
                    nama_lengkap: data.nama_lengkap,
                    email: data.email,
                    kata_sandi: hashedPassword,
                    jam_masuk_kerja: data.jam_masuk_kerja,
                    jam_keluar_kerja: data.jam_keluar_kerja,
                    jam_mulai_istirahat: data.jam_mulai_istirahat,
                    jam_selesai_istirahat: data.jam_selesai_istirahat
                }, { transaction: t }); // <-- Menautkan proses ini ke dalam transaksi 't'

                return newUser.id; 
                // Jika baris ini tercapai tanpa error, Sequelize otomatis melakukan COMMIT
            });

            return userId; 

        } catch (error) {
            // Jika ada error apa pun di dalam blok di atas, Sequelize otomatis melakukan ROLLBACK
            throw new Error('Gagal memproses pendaftaran pada sistem data: ' + error.message);
        }
    },

    loginPengguna: async (email, password) => {
        // Fungsi login tetap sama seperti sebelumnya karena tidak ada manipulasi data (hanya SELECT)
        const user = await Pengguna.findOne({ where: { email } });
        if (!user) {
            throw new Error('Email atau kata sandi salah.');
        }

        const isMatch = await bcrypt.compare(password, user.kata_sandi);
        if (!isMatch) {
            throw new Error('Email atau kata sandi salah.');
        }

        const token = jwt.sign(
            { id: user.id, peran: user.peran },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        const timeUtil = require('../utils/timeUtil');
        const jadwal_microbreak = timeUtil.calculateMicrobreaks(
            user.jam_masuk_kerja,
            user.jam_keluar_kerja,
            user.jam_mulai_istirahat,
            user.jam_selesai_istirahat
        );

        return {
            token,
            user: {
                id: user.id,
                nama_lengkap: user.nama_lengkap,
                email: user.email,
                peran: user.peran,
                jam_masuk_kerja: user.jam_masuk_kerja,
                jam_keluar_kerja: user.jam_keluar_kerja,
                jam_mulai_istirahat: user.jam_mulai_istirahat,
                jam_selesai_istirahat: user.jam_selesai_istirahat,
                jadwal_microbreak: jadwal_microbreak
            }
        };
    }
};

module.exports = authService;