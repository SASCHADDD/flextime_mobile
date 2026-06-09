const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { verifyToken, verifyAdmin } = require('../middlewares/authMiddleware');


router.post('/register', authController.register);
router.post('/login', authController.login);

router.get('/cek-sesi', verifyToken, (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Token valid. Sesi aktif.',
        pengguna: req.pengguna 
    });
});

module.exports = router;