const notifikasiService = require('../services/notifikasiservice');

const notifikasiController = {
    getKu: async (req, res) => {
        try {
            const pengguna_id = req.pengguna.id;
            const data = await notifikasiService.getNotifikasiUser(pengguna_id);
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    },

    readOne: async (req, res) => {
        try {
            const pengguna_id = req.pengguna.id;
            const { id } = req.params;
            const data = await notifikasiService.markAsRead(pengguna_id, id);
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    },

    readAll: async (req, res) => {
        try {
            const pengguna_id = req.pengguna.id;
            await notifikasiService.markAllAsRead(pengguna_id);
            res.status(200).json({ success: true, message: 'Semua notifikasi ditandai dibaca' });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    },

    create: async (req, res) => {
        try {
            const data = await notifikasiService.createNotifikasi(req.body);
            res.status(201).json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }
};

module.exports = notifikasiController;
