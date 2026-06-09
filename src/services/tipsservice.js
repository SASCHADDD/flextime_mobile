const Tips_Kesehatan = require('../models/tipsmodel');

const tipsService = {
    getAllTips: async () => {
        return await Tips_Kesehatan.findAll({
            order: [['id', 'DESC']] 
        });
    },

    getTipsById: async (id) => {
        const tips = await Tips_Kesehatan.findByPk(id);
        if (!tips) throw new Error('Tips tidak ditemukan.');
        return tips;
    },
};

module.exports = tipsService;