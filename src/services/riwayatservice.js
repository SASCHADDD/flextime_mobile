// File: src/services/riwayatService.js
const RiwayatKepatuhan = require('../models/riwayatmodel');
const Gerakan = require('../models/GerakanModel'); // Sesuaikan huruf besar/kecil dengan nama file Anda
const Pengguna = require('../models/PenggunaModel');
const timeUtil = require('../utils/timeUtil');

const riwayatService = {
    // [USER] Menyimpan riwayat baru ke MySQL
    createRiwayat: async (data) => {
        try {
            // Validasi: Cek apakah sesi untuk tanggal ini sudah tercatat sebelumnya
            const existing = await RiwayatKepatuhan.findOne({
                where: {
                    pengguna_id: data.pengguna_id,
                    tanggal: data.tanggal,
                    sesi: data.sesi
                }
            });

            if (existing) {
                // Jika sudah ada, lempar error tanpa stacktrace berlebih
                const err = new Error(`Riwayat untuk sesi ${data.sesi} pada hari ini sudah tersimpan.`);
                err.isDuplicate = true;
                throw err;
            }

            return await RiwayatKepatuhan.create(data);
        } catch (error) {
            if (error.isDuplicate) {
                throw error;
            }
            throw new Error('Gagal mencatat riwayat latihan: ' + error.message);
        }
    },

    // [USER] Menarik riwayat milik sendiri
    getRiwayatKu: async (idPengguna) => {
        try {
            // [LAZY CREATION] Catat otomatis sesi yang terlewat (Missed Session) untuk HARI INI
            const pengguna = await Pengguna.findByPk(idPengguna);
            if (pengguna) {
                const jadwalList = timeUtil.calculateMicrobreaks(
                    pengguna.jam_masuk_kerja,
                    pengguna.jam_keluar_kerja,
                    pengguna.jam_mulai_istirahat,
                    pengguna.jam_selesai_istirahat
                );

                const currentTime = new Date();
                const timeFormatter = new Intl.DateTimeFormat('id-ID', {
                    timeZone: 'Asia/Jakarta',
                    hour: '2-digit', minute: '2-digit', hour12: false
                });
                const totalCurrentMinutes = timeUtil.timeToMinutes(timeFormatter.format(currentTime));
                const dateFormatter = new Intl.DateTimeFormat('fr-CA', { timeZone: 'Asia/Jakarta' });
                const todayDateString = dateFormatter.format(currentTime);

                // Cek kapan user mendaftar (dalam menit Jakarta) jika mendaftar hari ini
                const userRegistrationDateString = dateFormatter.format(pengguna.dibuat_pada);
                const isUserRegisteredToday = (userRegistrationDateString === todayDateString);
                let totalRegistrationMinutes = 0;
                if (isUserRegisteredToday) {
                    totalRegistrationMinutes = timeUtil.timeToMinutes(timeFormatter.format(pengguna.dibuat_pada));
                }

                for (let i = 0; i < jadwalList.length; i++) {
                    const scheduleTimeString = jadwalList[i];
                    const totalScheduleMinutes = timeUtil.timeToMinutes(scheduleTimeString);

                    // Jika jadwal sudah lewat dari waktu saat ini
                    if (totalCurrentMinutes >= totalScheduleMinutes) {
                        // Jika user mendaftar hari ini, tapi jam daftarnya melebihi jam sesi ini, jangan catat missed session!
                        if (isUserRegisteredToday && totalRegistrationMinutes > totalScheduleMinutes) {
                            continue;
                        }
                        const sessionName = i === 0 ? 'Sesi 1' : i === 1 ? 'Sesi 2' : 'Sesi 3';

                        // Cek apakah riwayat ini sudah ada untuk hari ini
                        const existingRiwayat = await RiwayatKepatuhan.findOne({
                            where: { 
                                pengguna_id: idPengguna, 
                                sesi: sessionName,
                                tanggal: todayDateString
                            }
                        });

                        if (!existingRiwayat) {
                            // Hitung waktu jadwal sebenarnya
                            const scheduleDate = new Date(currentTime);
                            const scheduleParts = scheduleTimeString.split(':');
                            if (scheduleParts.length >= 2) {
                                scheduleDate.setHours(parseInt(scheduleParts[0], 10), parseInt(scheduleParts[1], 10), 0, 0);
                            }

                            await RiwayatKepatuhan.create({
                                pengguna_id: idPengguna,
                                tanggal: todayDateString,
                                sesi: sessionName,
                                status_kepatuhan: 'Tidak',
                                dibuat_pada: scheduleDate
                            });
                        }
                    }
                }
            }

            return await RiwayatKepatuhan.findAll({
                where: { pengguna_id: idPengguna },
                order: [['dibuat_pada', 'DESC']]
            });
        } catch (error) {
            throw new Error('Gagal mengambil riwayat kepatuhan: ' + error.message);
        }
    },

    // [ADMIN] Menarik riwayat berdasarkan ID dengan Pagination
    getRiwayatByPengguna: async (idPengguna, page = 1, limit = 15) => {
        try {
            const offset = (page - 1) * limit;

            return await RiwayatKepatuhan.findAndCountAll({
                where: { pengguna_id: idPengguna },
                limit: parseInt(limit),
                offset: parseInt(offset),
                order: [['dibuat_pada', 'DESC']] // Urutkan dari sesi latihan yang paling baru
            });
        } catch (error) {
            throw new Error('Gagal mengambil riwayat kepatuhan: ' + error.message);
        }
    }
};

module.exports = riwayatService;