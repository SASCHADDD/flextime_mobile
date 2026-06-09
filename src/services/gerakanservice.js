// File: src/services/gerakanService.js
const sequelize = require('../config/database');
const Gerakan = require('../models/gerakanmodel');
const fs = require('fs'); 
const path = require('path'); 

const gerakanService = {
    // READ ALL: Mengambil semua katalog gerakan
    getAllGerakan: async () => {
        return await Gerakan.findAll({
            order: [['dibuat_pada', 'DESC']]
        });
    },

    // READ ONE: Mengambil satu gerakan berdasarkan ID
    getGerakanById: async (id) => {
        const gerakan = await Gerakan.findByPk(id);
        if (!gerakan) throw new Error('Gerakan tidak ditemukan.');
        return gerakan;
    },

    // CREATE (TCL): Menambah gerakan baru
    createGerakan: async (data) => {
        try {
            const result = await sequelize.transaction(async (t) => {
                const gerakanBaru = await Gerakan.create(data, { transaction: t });
                return gerakanBaru;
            });
            return result;
        } catch (error) {
            throw new Error('Gagal menyimpan gerakan: ' + error.message);
        }
    },

   // UPDATE (TCL): Mengubah data gerakan
    updateGerakan: async (id, dataUpdate) => { 
        try {
            return await sequelize.transaction(async (t) => {
                const gerakan = await Gerakan.findByPk(id, { transaction: t });
                if (!gerakan) throw new Error('Gerakan tidak ditemukan.');

                // LOGIKA HAPUS GAMBAR LAMA SAAT UPDATE
                if (dataUpdate.gambar && gerakan.gambar) {
                    const oldFilePath = path.join(process.cwd(), gerakan.gambar);
                    if (fs.existsSync(oldFilePath)) {
                        fs.unlinkSync(oldFilePath); 
                    }
                }

                await gerakan.update(dataUpdate, { transaction: t });
                return gerakan; 
            });
        } catch (error) {
            throw new Error('Gagal memperbarui gerakan: ' + error.message);
        }
    },

    // DELETE (TCL): Menghapus gerakan
    deleteGerakan: async (id) => {
        try {
            await sequelize.transaction(async (t) => {
                const gerakan = await Gerakan.findByPk(id, { transaction: t });
                if (!gerakan) throw new Error('Gerakan tidak ditemukan.');

                // LOGIKA HAPUS GAMBAR FISIK SAAT DATA DIHAPUS
                if (gerakan.gambar) {
                    const filePath = path.join(process.cwd(), gerakan.gambar);
                    if (fs.existsSync(filePath)) {
                        fs.unlinkSync(filePath);
                    }
                }

                await gerakan.destroy({ transaction: t });
            });
            return true;
        } catch (error) {
            throw new Error('Gagal menghapus gerakan: ' + error.message);
        }
    }
};

module.exports = gerakanService; 