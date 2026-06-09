// File: src/models/GerakanModel.js
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Gerakan = sequelize.define('Gerakan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    nama_gerakan: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    deskripsi: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    durasi_detik: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 60 
    },
    gambar: {
        type: DataTypes.STRING(255),
        allowNull: true 
    }
}, {
    tableName: 'gerakan',
    timestamps: true,
    createdAt: 'dibuat_pada',
    updatedAt: 'diperbarui_pada'
});

module.exports = Gerakan;