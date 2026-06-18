import 'package:flutter/material.dart';

class TimeUtil {
  //Mencari jadwal sesi terdekat berikutnya berdasarkan daftar jadwal dari server dan waktu saat ini (TimeOfDay.now())
  static String getNextSessionTime(List<String> jadwal, List<dynamic> riwayatsToday) {
    String nextSessionTime = '--:--';
    if (jadwal.isNotEmpty) {
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;

      for (int i = 0; i < jadwal.length; i++) {
        final timeStr = jadwal[i];
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          final timeMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          // Pembatas: 1 jam (60 menit) setelah jam yang dijadwalkan
          if ((timeMin + 60) > nowMinutes) {
            String sessionName = i == 0 ? 'Sesi 1' : (i == 1 ? 'Sesi 2' : 'Sesi 3');
            bool isDone = riwayatsToday.any((r) => 
                r.sesi.toLowerCase() == sessionName.toLowerCase() && 
                r.statusKepatuhan.toLowerCase() == 'melakukan'
            );

            if (!isDone) {
              nextSessionTime = timeStr;
              // Jika formatnya HH:MM:SS, potong menjadi HH:MM
              if (nextSessionTime.length > 5) {
                nextSessionTime = nextSessionTime.substring(0, 5);
              }
              break; // Ambil jadwal pertama yang belum lewat dan belum selesai
            }
          }
        }
      }
    }
    return nextSessionTime;
  }

  /// Menentukan nama sesi saat ini (Pagi, Siang, atau Sore)
  /// Berdasarkan jadwal dinamis pengguna dan pembatas 1 jam (60 menit)
  static String getCurrentSessionName(List<String> jadwal) {
    if (jadwal.isEmpty) return 'Sesi 1'; // Fallback

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (int i = 0; i < jadwal.length; i++) {
      final parts = jadwal[i].split(':');
      if (parts.length >= 2) {
        final timeMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if ((timeMin + 60) > nowMinutes) {
          if (i == 0) return 'Sesi 1';
          if (i == 1) return 'Sesi 2';
          if (i == 2) return 'Sesi 3';
        }
      }
    }
    // Jika semua sesi hari ini sudah terlewat, lemparkan ke sesi terakhir
    return 'Sesi 3';
  }

  /// Cek apakah tombol FlexTime! boleh ditekan saat ini
  /// Syarat: Waktu sekarang harus berada di dalam rentang [Jadwal] hingga [Jadwal + 60 menit]
  static bool isFlexTimeButtonActive(List<String> jadwal) {
    if (jadwal.isEmpty) return false;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (String timeStr in jadwal) {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final timeMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        // Cek apakah sekarang berada di dalam Jendela Waktu (1 Jam)
        if (nowMinutes >= timeMin && nowMinutes <= (timeMin + 60)) {
          return true;
        }
      }
    }
    return false;
  }
}
