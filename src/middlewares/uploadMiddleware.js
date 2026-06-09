const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Buat folder otomatis jika belum ada di root proyek
const direktoriUpload = './uploads/gerakan';
if (!fs.existsSync(direktoriUpload)) {
    fs.mkdirSync(direktoriUpload, { recursive: true });
}

// Konfigurasi penyimpanan lokal
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, direktoriUpload); // File akan disimpan di folder uploads/gerakan/
    },
    filename: (req, file, cb) => {
        // Ganti nama file dengan tambahan timestamp agar unik (contoh: gerakan-16843920.jpg)
        const namaUnik = 'gerakan-' + Date.now() + path.extname(file.originalname);
        cb(null, namaUnik);
    }
});

const fileFilter = (req, file, cb) => {
    const tipeDiizinkan = /jpeg|jpg|png|gif/;
    const extName = tipeDiizinkan.test(path.extname(file.originalname).toLowerCase());
    const mimeType = tipeDiizinkan.test(file.mimetype);

    if (extName && mimeType) {
        return cb(null, true);
    } else {
        cb(new Error('Hanya diperbolehkan mengunggah file gambar (JPG, PNG, GIF)!'), false);
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // <-- Ubah angka 2 menjadi 5 di sini
    fileFilter: fileFilter
});

module.exports = upload;