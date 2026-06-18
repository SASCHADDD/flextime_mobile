// File: src/utils/timeUtil.js

const timeUtil = {
    // Helper to convert "HH:mm:ss" or "HH:mm" or "HH.mm" to total minutes
    timeToMinutes: (timeStr) => {
        if (!timeStr) return 0;
        // Dukung pemisah titik (.) dan titik dua (:)
        const parts = timeStr.replace('.', ':').split(':');
        const h = parseInt(parts[0], 10) || 0;
        const m = parseInt(parts[1], 10) || 0;
        return h * 60 + m;
    },

    // Helper to convert total minutes back to "HH:mm"
    minutesToTime: (minutes) => {
        const h = Math.floor(minutes / 60);
        const m = Math.floor(minutes % 60);
        const hh = h.toString().padStart(2, '0');
        const mm = m.toString().padStart(2, '0');
        return `${hh}:${mm}`;
    },

    calculateMicrobreaks: (jamMasuk, jamKeluar, jamMulaiIstirahat, jamSelesaiIstirahat) => {
        // Fallbacks for invalid inputs
        const startWork = timeUtil.timeToMinutes(jamMasuk || "08:00");
        let endWork = timeUtil.timeToMinutes(jamKeluar || "17:00");
        const startRest = timeUtil.timeToMinutes(jamMulaiIstirahat || "12:00");
        const endRest = timeUtil.timeToMinutes(jamSelesaiIstirahat || "13:00");

        // Handle case if endWork is on the next day (e.g. shift malam)
        if (endWork <= startWork) {
            endWork += 24 * 60; // add 24 hours
        }

        let durationBlok1 = startRest - startWork;
        let durationBlok2 = endWork - endRest;

        // SAFEGUARD LOOPHOLE:
        // Jika Blok 2 terlalu pendek (kurang dari 60 menit) atau Blok 1 negatif/terlalu pendek
        // Berarti jadwal istirahatnya tidak proporsional. Kita gunakan Fallback (sebar rata 3 sesi).
        if (durationBlok1 < 30 || durationBlok2 < 60) {
            const totalWork = endWork - startWork;
            const sesiPagi = startWork + Math.floor(totalWork * 0.25);
            const sesiSiang = startWork + Math.floor(totalWork * 0.50);
            const sesiSore = startWork + Math.floor(totalWork * 0.75);

            return [
                timeUtil.minutesToTime(sesiPagi % (24 * 60)),
                timeUtil.minutesToTime(sesiSiang % (24 * 60)),
                timeUtil.minutesToTime(sesiSore % (24 * 60))
            ];
        }

        // Jika normal, gunakan logika standar:
        // Blok 1 (Pagi): Diletakkan tepat di Tengah-tengah (50%) Blok 1.
        const sesiPagi = startWork + Math.floor(durationBlok1 * 0.5);

        // Blok 2 (Siang - Sore):
        // Sesi 2 (Siang): Diletakkan di Sepertiga awal (33.3%) Blok 2.
        // Sesi 3 (Sore): Diletakkan di Dua pertiga (66.6%) Blok 2.
        const sesiSiang = endRest + Math.floor(durationBlok2 * 0.3333);
        const sesiSore = endRest + Math.floor(durationBlok2 * 0.6667);

        return [
            timeUtil.minutesToTime(sesiPagi % (24 * 60)),
            timeUtil.minutesToTime(sesiSiang % (24 * 60)),
            timeUtil.minutesToTime(sesiSore % (24 * 60))
        ];
    }
};

module.exports = timeUtil;
