const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Pengguna = require('./penggunamodel');

const Notifikasi = sequelize.define('Notifikasi', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    pengguna_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: Pengguna,
            key: 'id'
        }
    },
    judul: {
        type: DataTypes.STRING,
        allowNull: false
    },
    pesan: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    tipe: {
        type: DataTypes.ENUM('success', 'info', 'warning', 'error'),
        defaultValue: 'info'
    },
    is_read: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    tableName: 'notifikasi',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
});

// Associations
Pengguna.hasMany(Notifikasi, { foreignKey: 'pengguna_id', onDelete: 'CASCADE' });
Notifikasi.belongsTo(Pengguna, { foreignKey: 'pengguna_id' });

module.exports = Notifikasi;
