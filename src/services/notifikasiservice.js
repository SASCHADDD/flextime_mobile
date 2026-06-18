const Notifikasi = require('../models/notifikasimodel');
const Pengguna = require('../models/PenggunaModel');
const timeUtil = require('../utils/timeUtil');

const notifikasiService = {
    getNotifikasiUser: async (pengguna_id) => {
        try {
            // AUTO Cek jadwal dan buat notifikasi jika sudah lewat
            const pengguna = await Pengguna.findByPk(pengguna_id);
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

                // const [currentHour, currentMinute] = timeFormatter.format(currentTime).split(/[:.]/);
                // const totalCurrentMinutes = parseInt(currentHour) * 60 + parseInt(currentMinute);
                const totalCurrentMinutes = timeUtil.timeToMinutes(timeFormatter.format(currentTime));
                
                // Gunakan format YYYY-MM-DD waktu Jakarta
                const dateFormatter = new Intl.DateTimeFormat('fr-CA', { timeZone: 'Asia/Jakarta' });
                const todayDateString = dateFormatter.format(currentTime);

                // Cek kapan user mendaftar (dalam menit Jakarta) jika mendaftar hari ini
                const userRegistrationDateString = dateFormatter.format(pengguna.dibuat_pada);
                const isUserRegisteredToday = (userRegistrationDateString === todayDateString);
                let totalRegistrationMinutes = 0;
                if (isUserRegisteredToday) {

                    // const [registrationHour, registrationMinute] = timeFormatter.format(pengguna.dibuat_pada).split(/[:.]/);
                    // totalRegistrationMinutes = parseInt(registrationHour) * 60 + parseInt(registrationMinute);
                    totalRegistrationMinutes = timeUtil.timeToMinutes(timeFormatter.format(pengguna.dibuat_pada));
                }

                for (let i = 0; i < jadwalList.length; i++) {
                    const scheduleTimeString = jadwalList[i];

                    // if (!scheduleTimeString) continue;
                        //karna di utils/timeUtil.js sudah ada fungsi timeToMinutes, kita bisa pakai itu untuk konversi
                    // const scheduleTimeParts = scheduleTimeString.split(':');
                    // if (scheduleTimeParts.length < 2) continue;
    
                    // const totalScheduleMinutes = parseInt(scheduleTimeParts[0]) * 60 + parseInt(scheduleTimeParts[1]);
                    const totalScheduleMinutes = timeUtil.timeToMinutes(scheduleTimeString);

                    // Jika jadwal sudah lewat dari waktu saat ini
                    if (totalCurrentMinutes >= totalScheduleMinutes) {
                        // Jika user mendaftar hari ini, tapi jam daftarnya melebih jam sesi ini, jangan buat notifikasi!
                        if (isUserRegisteredToday && totalRegistrationMinutes > totalScheduleMinutes) {
                            continue;
                        }

                        const sessionName = i === 0 ? 'Sesi 1' : i === 1 ? 'Sesi 2' : 'Sesi 3';
                        const notificationTitle = `Waktunya FlexTime! (${sessionName})`;
                        
                        // Cek apakah notifikasi ini sudah ada untuk hari ini
                        const existingNotification = await Notifikasi.findOne({
                            where: { pengguna_id, judul: notificationTitle },
                            order: [['created_at', 'DESC']]
                        });

                        let isNotificationCreatedToday = false;
                        if (existingNotification && existingNotification.created_at) {
                            const notificationCreationDateString = dateFormatter.format(existingNotification.created_at);
                            if (notificationCreationDateString === todayDateString) isNotificationCreatedToday = true;
                        }

                        if (!isNotificationCreatedToday) {
                            // Hitung waktu jadwal yang sebenarnya agar "0mnt lalu" tidak muncul saat telat buka notif
                            const scheduleDate = new Date(currentTime);
                            const scheduleParts = scheduleTimeString.split(':');
                            if (scheduleParts.length >= 2) {
                                scheduleDate.setHours(parseInt(scheduleParts[0], 10), parseInt(scheduleParts[1], 10), 0, 0);
                            }

                            await Notifikasi.create({
                                pengguna_id,
                                judul: notificationTitle,
                                pesan: 'Mari luangkan sedikit waktu untuk peregangan agar tubuh tetap fit.',
                                tipe: 'info',
                                created_at: scheduleDate
                            });
                        }
                    }
                }
            }

            return await Notifikasi.findAll({
                where: { pengguna_id },
                order: [['created_at', 'DESC']]
            });
        } catch (error) {
            throw new Error('Gagal mengambil notifikasi: ' + error.message);
        }
    },

    markAsRead: async (pengguna_id, notifikasi_id) => {
        try {
            const notif = await Notifikasi.findOne({
                where: { id: notifikasi_id, pengguna_id }
            });
            if (!notif) throw new Error('Notifikasi tidak ditemukan');
            
            await notif.update({ is_read: true });
            return notif;
        } catch (error) {
            throw new Error('Gagal menandai dibaca: ' + error.message);
        }
    },

    markAllAsRead: async (pengguna_id) => {
        try {
            await Notifikasi.update(
                { is_read: true },
                { where: { pengguna_id, is_read: false } }
            );
            return true;
        } catch (error) {
            throw new Error('Gagal menandai semua dibaca: ' + error.message);
        }
    },

    // Untuk admin / push system
    createNotifikasi: async (data) => {
        try {
            return await Notifikasi.create({
                pengguna_id: data.pengguna_id,
                judul: data.judul,
                pesan: data.pesan,
                tipe: data.tipe || 'info'
            });
        } catch (error) {
            throw new Error('Gagal membuat notifikasi: ' + error.message);
        }
    }
};

module.exports = notifikasiService;
