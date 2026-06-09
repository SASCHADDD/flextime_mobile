// File: src/controllers/gerakanController.js
const gerakanService = require('../services/gerakanService');

const gerakanController = {
    getAll: async (req, res) => {
        try {
            const data = await gerakanService.getAllGerakan();
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    },

    getById: async (req, res) => {
        try {
            const data = await gerakanService.getGerakanById(req.params.id);
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    },

    create: async (req, res) => {
        try {
            // Ambil data teks (nama_gerakan, dll)
            const dataGerakan = req.body; 

            // Jika ada file gambar yang diunggah, simpan path-nya
            if (req.file) {
                // Menyimpan path relatif agar mudah dipanggil oleh Frontend
                dataGerakan.gambar = `/uploads/gerakan/${req.file.filename}`;
            }

            const data = await gerakanService.createGerakan(dataGerakan);
            res.status(201).json({ success: true, message: 'Gerakan berhasil ditambahkan.', data });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    },

    update: async (req, res) => {
        try {
            const dataUpdate = { ...req.body };

            if (req.file) {
                dataUpdate.gambar = `/uploads/gerakan/${req.file.filename}`;
            }

            // Kirim data murni (bukan req/res) ke Service
            const data = await gerakanService.updateGerakan(req.params.id, dataUpdate);
            
            // Controller yang berhak membalas dengan res.status
            res.status(200).json({ 
                success: true, 
                message: 'Gerakan berhasil diperbarui.', 
                data 
            });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    },
    
    delete: async (req, res) => {
        try {
            await gerakanService.deleteGerakan(req.params.id);
            res.status(200).json({ success: true, message: 'Gerakan berhasil dihapus.' });
        } catch (error) {
            res.status(400).json({ success: false, message: error.message });
        }
    }
};

module.exports = gerakanController;