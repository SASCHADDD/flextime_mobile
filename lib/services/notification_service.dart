import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> scheduleMicrobreaks(List<String> times) async {
    // 1. Batalkan semua alarm microbreak lama
    await flutterLocalNotificationsPlugin.cancelAll();

    // 2. Daftarkan ulang
    int id = 0;
    for (String timeStr in times) {
      if (timeStr.isEmpty) continue;
      
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await _scheduleDailyNotification(id, hour, minute);
      id++;
    }
  }

  Future<void> _scheduleDailyNotification(int id, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'microbreak_channel',
      'Pengingat FlexTime',
      channelDescription: 'Alarm untuk mengingatkan waktu peregangan',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'Waktunya FlexTime!',
      body: 'Mari luangkan sedikit waktu untuk peregangan agar tubuh tetap fit.',
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
