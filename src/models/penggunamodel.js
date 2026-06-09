// File: src/models/PenggunaModel.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Pengguna = sequelize.define('Pengguna', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    nama_lengkap: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    email: {
        type: DataTypes.STRING(100),
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true // Validasi otomatis di tingkat ORM
        }
    },
    kata_sandi: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    jam_masuk_kerja: {
        type: DataTypes.TIME,
        defaultValue: '08:00:00'
    },
    jam_keluar_kerja: {
        type: DataTypes.TIME,
        defaultValue: '17:00:00'
    },
    jam_mulai_istirahat: {
        type: DataTypes.TIME,
        defaultValue: '12:00:00'
    },
    jam_selesai_istirahat: {
        type: DataTypes.TIME,
        defaultValue: '13:00:00'
    },
    peran: {
        type: DataTypes.ENUM('admin', 'user'),
        defaultValue: 'user'
    }
}, {
    tableName: 'pengguna', // Memastikan nama tabel tetap huruf kecil sesuai blueprint awal
    timestamps: true, // Otomatis membuat kolom createdAt & updatedAt
    createdAt: 'dibuat_pada',
    updatedAt: 'diperbarui_pada'
});

module.exports = Pengguna;