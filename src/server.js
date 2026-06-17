require('dotenv').config();
const express = require('express');
const cors = require('cors');
require('./config/database'); 
const path = require('path');
const app = express(); 
const port = process.env.PORT || 3000;

// MIDDLEWARE 
app.use(cors());
app.use(express.json()); 
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// PENDAFTARAN RUTE
const authRoutes = require('./routes/authroute'); 
const gerakanRoutes = require('./routes/gerakanroute');
const tipsRoutes = require('./routes/tipsroute');
const penggunaRoutes = require('./routes/penggunaRoute');
const riwayatRoutes = require('./routes/riwayatRoute');
const notifikasiRoutes = require('./routes/notifikasiRoutes');
// Baru disalurkan ke rute masing-masing setelah JSON terbaca
app.use('/api/auth', authRoutes);
app.use('/api/gerakan', gerakanRoutes);
app.use('/api/tips', tipsRoutes);
app.use('/api/pengguna', penggunaRoutes);
app.use('/api/riwayat', riwayatRoutes);
app.use('/api/notifikasi', notifikasiRoutes);
// Endpoint tes untuk memastikan server menyala
app.get('/api/ping', (req, res) => {
    res.status(200).json({ 
        success: true, 
        message: 'FlexTime Backend API is running smoothly!' 
    });
});

// Custom Error Handler (Mencegah Express mengembalikan HTML jika terjadi error internal/multer)
app.use((err, req, res, next) => {
    console.error('[ERROR]', err);
    if (err instanceof SyntaxError) {
        return res.status(400).json({ success: false, message: 'Bad Request: ' + err.message });
    }
    res.status(500).json({ success: false, message: 'Server Error: ' + err.message });
});

// Menjalankan Server
app.listen(port, () => {
    console.log(`[SERVER] FlexTime API berjalan di http://localhost:${port}`);
});