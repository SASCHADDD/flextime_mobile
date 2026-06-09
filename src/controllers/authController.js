const authService = require('../services/authservice');

const authController = {
    register: async (req, res) => {
        try {
            // Controller melempar tugas ke Service
            const insertId = await authService.registerPengguna(req.body);
            
            res.status(201).json({
                success: true,
                message: 'Registrasi berhasil',
                data: { id: insertId }
            });
        } catch (error) {
            // Tangkap pesan error dari Service (misal: "Email sudah terdaftar")
            res.status(400).json({ success: false, message: error.message });
        }
    },

    login: async (req, res) => {
        try {
            const { email, kata_sandi } = req.body;
            const result = await authService.loginPengguna(email, kata_sandi);
            
            res.status(200).json({
                success: true,
                message: 'Login berhasil',
                data: result
            });
        } catch (error) {
            res.status(401).json({ success: false, message: error.message });
        }
    }
};

module.exports = authController;