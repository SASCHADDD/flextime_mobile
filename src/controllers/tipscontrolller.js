const tipsService = require('../services/tipsservice');
const tipsController = {
    getAll: async (req, res) => {
        try {
            const data = await tipsService.getAllTips();
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    },

    getById: async (req, res) => {
        try {
            const data = await tipsService.getTipsById(req.params.id);
            res.status(200).json({ success: true, data });
        } catch (error) {
            res.status(404).json({ success: false, message: error.message });
        }
    },
};

module.exports = tipsController;