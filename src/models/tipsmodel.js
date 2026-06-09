const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Tips_Kesehatan = sequelize.define('Tips_Kesehatan', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    kondisi_pemicu: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    judul: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    konten_pesan: {
        type: DataTypes.TEXT,
        allowNull: false
    }
}, {
    tableName: 'tips_kesehatan',
    timestamps: false,
});

module.exports = Tips_Kesehatan;