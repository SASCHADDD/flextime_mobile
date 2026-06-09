// File: src/models/riwayatmodel.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Pengguna = require('./penggunamodel');
const Gerakan = require('./GerakanModel');

const RiwayatKepatuhan = sequelize.define('RiwayatKepatuhan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    pengguna_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'pengguna', // Menghubungkan ke nama tabel fisik pengguna di MySQL
            key: 'id'
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE'
    },
    gerakan_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'gerakan', // Menghubungkan ke nama tabel fisik gerakan di MySQL
            key: 'id'
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE'
    },
    sesi: {
        type: DataTypes.ENUM('Pagi', 'Siang', 'Sore'),
        allowNull: false
    },
    status_kepatuhan: {
        type: DataTypes.ENUM('Melakukan', 'Tidak'),
        allowNull: false,
        defaultValue: 'Tidak'
    },
    durasi_detik: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0 // Menyimpan total durasi latihan dalam hitungan detik
    }
}, {
    tableName: 'riwayat_kepatuhan', // Nama tabel sesuai pangkalan data Anda
    timestamps: true,
    createdAt: 'dibuat_pada',
    updatedAt: 'diperbarui_pada'
});

// MEMBENTUK RELASI (ASSOCIATIONS) DI SEQUELIZE
// Ini sangat penting agar Admin bisa menggunakan fitur .findAll({ include: [...] })
RiwayatKepatuhan.belongsTo(Pengguna, { foreignKey: 'pengguna_id', as: 'pengguna' });
RiwayatKepatuhan.belongsTo(Gerakan, { foreignKey: 'gerakan_id', as: 'gerakan' });

module.exports = RiwayatKepatuhan;