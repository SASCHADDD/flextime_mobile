// File: src/config/database.js
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT,
        dialect: 'mysql',
        logging: false, 
        pool: {
            max: 10,
            min: 0,
            acquire: 30000,
            idle: 10000
        }
    }
);

const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log(`[DATABASE] ORM Sequelize berhasil terhubung di port ${process.env.DB_PORT}`);
        
        await sequelize.sync();
        console.log('[DATABASE] Sinkronisasi tabel selesai.');
    } catch (error) {
        console.error('[DATABASE] Gagal terhubung ke MySQL via Sequelize:', error.message);
        process.exit(1);
    }
};

testConnection();

module.exports = sequelize;