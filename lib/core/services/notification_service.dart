import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(settings);
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }

    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Notification permissions request failed: $e');
    }
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
        channelDescription: 'ওষুধ খাওয়ার রিমাইন্ডার',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    for (final day in daysOfWeek) {
      try {
        final scheduledDate = _nextInstanceOfDay(hour, minute, day);
        final notificationId = reminderId * 10 + day;

        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('Failed to schedule notification for day $day: $e');
      }
    }
  }

  Future<void> cancelReminderNotifications(int reminderId) async {
    for (int day = 1; day <= 7; day++) {
      try {
        await _notifications.cancel(reminderId * 10 + day);
      } catch (_) {}
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  tz.TZDateTime _nextInstanceOfDay(int hour, int minute, int dayOfWeek) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    int attempts = 0;
    while (scheduled.weekday != dayOfWeek && attempts < 8) {
      scheduled = scheduled.add(const Duration(days: 1));
      attempts++;
    }

    return scheduled;
  }
}
