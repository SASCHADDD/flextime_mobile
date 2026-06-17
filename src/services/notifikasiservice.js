const Notifikasi = require('../models/notifikasimodel');
const Pengguna = require('../models/PenggunaModel');
const timeUtil = require('../utils/timeUtil');

const notifikasiService = {
    getNotifikasiUser: async (pengguna_id) => {
        try {
            // [AUTO-GENERATE] Cek jadwal dan buat notifikasi jika sudah lewat
            const pengguna = await Pengguna.findByPk(pengguna_id);
            if (pengguna) {
                const jadwalList = timeUtil.calculateMicrobreaks(
                    pengguna.jam_masuk_kerja,
                    pengguna.jam_keluar_kerja,
                    pengguna.jam_mulai_istirahat,
                    pengguna.jam_selesai_istirahat
                );
                
                const now = new Date();
                const formatter = new Intl.DateTimeFormat('id-ID', {
                    timeZone: 'Asia/Jakarta',
                    hour: '2-digit', minute: '2-digit', hour12: false
                });
                const [hour, minute] = formatter.format(now).split(/[:.]/);
                const currentMinutes = parseInt(hour) * 60 + parseInt(minute);
                
                // Gunakan format YYYY-MM-DD waktu Jakarta
                const todayFormatter = new Intl.DateTimeFormat('fr-CA', { timeZone: 'Asia/Jakarta' });
                const todayStr = todayFormatter.format(now);

                // Cek kapan user mendaftar (dalam menit Jakarta) jika mendaftar hari ini
                const createdAtDateStr = todayFormatter.format(pengguna.dibuat_pada);
                const isRegisteredToday = (createdAtDateStr === todayStr);
                let registeredMinutes = 0;
                if (isRegisteredToday) {
                    const [regHour, regMinute] = formatter.format(pengguna.dibuat_pada).split(/[:.]/);
                    registeredMinutes = parseInt(regHour) * 60 + parseInt(regMinute);
                }

                for (let i = 0; i < jadwalList.length; i++) {
                    const timeStr = jadwalList[i];
                    if (!timeStr) continue;
                    
                    const parts = timeStr.split(':');
                    if (parts.length < 2) continue;
                    
                    const schedMinutes = parseInt(parts[0]) * 60 + parseInt(parts[1]);

                    // Jika jadwal sudah lewat dari waktu saat ini
                    if (currentMinutes >= schedMinutes) {
                        // Jika user mendaftar hari ini, tapi jam daftarnya melebih jam sesi ini, jangan buat notifikasi!
                        if (isRegisteredToday && registeredMinutes > schedMinutes) {
                            continue;
                        }

                        const sesiName = i === 0 ? 'Sesi 1' : i === 1 ? 'Sesi 2' : 'Sesi 3';
                        const judul = `Waktunya FlexTime! (${sesiName})`;
                        
                        // Cek apakah notifikasi ini sudah ada untuk hari ini
                        const existing = await Notifikasi.findOne({
                            where: { pengguna_id, judul },
                            order: [['created_at', 'DESC']]
                        });

                        let isToday = false;
                        if (existing && existing.created_at) {
                            const createdDateStr = todayFormatter.format(existing.created_at);
                            if (createdDateStr === todayStr) isToday = true;
                        }

                        if (!isToday) {
                            await Notifikasi.create({
                                pengguna_id,
                                judul: judul,
                                pesan: 'Mari luangkan sedikit waktu untuk peregangan agar tubuh tetap fit.',
                                tipe: 'info'
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
