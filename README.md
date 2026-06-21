# FlexTime Mobile & Backend

FlexTime adalah aplikasi produktivitas dan kesehatan yang dirancang untuk mengingatkan pengguna agar mengambil jeda sejenak dari pekerjaan dan melakukan gerakan peregangan (stretching). Proyek ini terdiri dari aplikasi mobile berbasis Flutter dan backend berbasis Node.js/Express.

## 🎯 Problem Statement (Latar Belakang Masalah)

Banyak pekerja modern atau pelajar yang menghabiskan waktu berjam-jam duduk di depan layar komputer secara terus-menerus (sedentary lifestyle). Kebiasaan ini sering kali membuat mereka lupa untuk mengambil waktu istirahat yang cukup, yang pada akhirnya dapat memicu berbagai masalah kesehatan seperti nyeri punggung, kelelahan mata, Postur tubuh yang buruk, hingga _Repetitive Strain Injury_ (RSI). Penurunan kesehatan fisik ini juga berbanding lurus dengan penurunan produktivitas dan kesejahteraan mental. 

FlexTime hadir untuk memecahkan masalah ini dengan menyediakan aplikasi yang dapat mengatur penjadwalan waktu kerja dan istirahat (microbreaks), serta secara proaktif mengingatkan pengguna untuk melakukan gerakan peregangan yang dipandu langsung melalui aplikasi.

---

## ✨ List Features (Fitur-Fitur)

### Aplikasi Mobile (Flutter)
- **Autentikasi (Login & Registrasi):** Pengguna dapat membuat akun dan masuk secara aman.
- **Dashboard (Beranda):** Tampilan ringkasan aktivitas harian dan informasi jadwal sesi peregangan selanjutnya.
- **Sesi Peregangan (FlexTime Timer):** Fitur utama berupa timer yang menghitung waktu kerja dan memberikan notifikasi kapan harus istirahat serta melakukan gerakan peregangan.
- **Sistem Notifikasi Lokal:** Pengingat (reminder) otomatis agar pengguna mengambil jeda kerja.
- **Riwayat & Laporan:** Pemantauan kepatuhan pengguna terhadap jadwal peregangan, dicatat dalam bentuk riwayat harian.
- **Tips Kesehatan:** Menampilkan artikel atau tips terkait ergonomi dan kesehatan fisik.
- **Profil Pengguna:** Manajemen data diri serta pengaturan durasi waktu kerja dan jeda (waktu istirahat).
- **Panel Admin:** Hak akses khusus admin untuk mengelola data gerakan peregangan (CRUD) dan data pengguna aplikasi.
- **Clean Architecture & BLoC:** Pengelolaan state dan arsitektur kode yang terstruktur rapi untuk skalabilitas.

### Backend (Node.js, Express, MySQL)
- **RESTful API:** Berfungsi sebagai jembatan komunikasi data dengan aplikasi mobile.
- **Keamanan (JWT & Bcrypt):** Autentikasi menggunakan JSON Web Token dan enkripsi kata sandi yang aman.
- **Manajemen Pengguna & Role:** Endpoint untuk mengelola pengguna biasa dan admin.
- **CRUD Gerakan & Tips:** Endpoint untuk menambah, mengedit, dan menghapus panduan gerakan dan artikel kesehatan.
- **Sistem Rekam Riwayat:** Algoritma untuk menghitung status kepatuhan sesi, _lazy session creation_ untuk sesi yang terlewat, dan kalkulasi _microbreak_.
- **Layanan Notifikasi:** Modul jadwal dan data notifikasi pengguna di database.
- **Penyimpanan File (Multer):** Layanan unggah gambar untuk ilustrasi panduan gerakan.

---

## 📈 Progress Mingguan

Proses pengembangan proyek dikerjakan secara bertahap, berikut adalah rangkuman progres mingguan dari repositori Mobile maupun Backend:

### Minggu 1 (Fokus: Inisialisasi & Basis Data)
- **Backend:** Inisialisasi server dengan Express, konfigurasi database MySQL menggunakan Sequelize, dan pembuatan skema database awal (Pengguna, Gerakan, Tips).
- **Mobile:** Pengaturan awal proyek Flutter menggunakan pendekatan **Clean Architecture**.
- **Mobile:** Menyiapkan struktur direktori utama (Data, Logic, UI, Services) serta mengatur _dependency_ penting (BLoC, HTTP, Shared Preferences).

### Minggu 2 (Fokus: Autentikasi, UI Dasar & Navigasi)
- **Backend:** Pembuatan endpoint REST API untuk Autentikasi (Register dan Login) menggunakan enkripsi Bcrypt dan integrasi JWT.
- **Mobile:** Pembuatan antarmuka modul Autentikasi (Login & Register page) dan integrasi state management (AuthBLoC) dengan API.
- **Mobile:** Pembangunan navigasi dasar (_Custom Bottom Navigation Bar_) serta struktur UI awal untuk Beranda, Profil, dan Laporan.

### Minggu 3 (Fokus: Fitur Inti - Sesi Latihan, Notifikasi & Riwayat)
- **Backend:** Penambahan utilitas waktu (_time utility_) untuk menghitung rentang sesi kerja dan mengatur jeda otomatis, serta endpoint CRUD Notifikasi.
- **Backend:** Integrasi sistem _lazy session creation_ untuk penanganan data riwayat harian otomatis.
- **Mobile:** Pengembangan fitur pengatur waktu (_TimePicker_) agar pengguna dapat mengustomisasi durasi kerja dan istirahatnya.
- **Mobile:** Integrasi `flutter_local_notifications` untuk penjadwalan alarm dan notifikasi pengingat sesi peregangan.
- **Mobile:** Implementasi BLoC untuk memantau sesi latihan, menampilkan daftar gerakan, dan menyinkronkan data riwayat ke backend.

### Minggu 4 (Fokus: Fitur Admin, Refactoring & Penyempurnaan UX)
- **Backend:** Pengembangan dan optimasi CRUD untuk manajemen Gerakan dan Artikel Tips, beserta dukungan _upload_ gambar (_upload size limit_ dengan Multer).
- **Mobile:** Pembangunan fitur **Panel Admin** khusus, mencakup form penambahan/pengubahan data Gerakan dan tabel pemantauan data pengguna.
- **Mobile:** Implementasi manajemen _loading state_ (memuat lebih banyak data / _pagination_ untuk pengguna) dan tips kesehatan.
- **Mobile & Backend:** Refactoring logika kode, perbaikan dan penyeragaman _error handling_, peningkatan antarmuka (_Custom Error/Success Dialog_, SnackbarUtil), dan proses sinkronisasi akhir.
