import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);
  }

  Future<void> showNotification(int id, String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_guide_immediate',
        'Immediate Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _notifications.show(id, title, body, details);
  }

  Future<void> scheduleWeeklyNotification({
    required int reminderId,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> daysOfWeek,
  }) async {
    await cancelReminderNotifications(reminderId);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_guide_reminders',
        'Medicine Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final day in daysOfWeek) {
      final scheduledDate = _nextInstance(hour, minute, day);
      final notificationId = reminderId * 10 + day;

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminderNotifications(int reminderId) async {
    for (int day = 1; day <= 7; day++) {
      await _notifications.cancel(reminderId * 10 + day);
    }
  }

  tz.TZDateTime _nextInstance(int hour, int minute, int dayOfWeek) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
