// File: src/models/riwayatmodel.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Pengguna = require('./penggunamodel');

const RiwayatKepatuhan = sequelize.define('RiwayatKepatuhan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    pengguna_id: {
        type: DataTypes.INTEGER,
        field: 'id_pengguna',
        allowNull: false,
        references: {
            model: 'pengguna',
            key: 'id'
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE'
    },
    tanggal: {
        type: DataTypes.DATEONLY,
        allowNull: false
    },
    sesi: {
        type: DataTypes.ENUM('Pagi', 'Siang', 'Sore', 'Sesi 1', 'Sesi 2', 'Sesi 3'),
        field: 'periode_sesi',
        allowNull: false
    },
    status_kepatuhan: {
        type: DataTypes.ENUM('Melakukan', 'Tidak'),
        field: 'status',
        allowNull: false,
        defaultValue: 'Tidak'
    }
}, {
    tableName: 'riwayat_kepatuhan',
    timestamps: true,
    createdAt: 'dibuat_pada',
    updatedAt: false
});

// MEMBENTUK RELASI (ASSOCIATIONS) DI SEQUELIZE
RiwayatKepatuhan.belongsTo(Pengguna, { foreignKey: 'id_pengguna', as: 'pengguna' });

module.exports = RiwayatKepatuhan;