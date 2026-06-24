import 'package:flutter/foundation.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/notification_service.dart';
import 'package:medicine_guide_ai/features/reminder/data/models/reminder_model.dart';
import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';
import 'package:medicine_guide_ai/features/reminder/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final DatabaseHelper _db;
  final NotificationService _notifications;

  ReminderRepositoryImpl(this._db, this._notifications);

  @override
  Future<List<Reminder>> getReminders() async {
    final rows = await _db.getReminders();
    return rows.map((r) => ReminderModel.fromMap(r)).toList();
  }

  @override
  Future<int> addReminder(Reminder reminder) async {
    final model = ReminderModel(
      medicineName: reminder.medicineName,
      time: reminder.time,
      daysOfWeek: reminder.daysOfWeek,
      isActive: reminder.isActive,
      doseDescription: reminder.doseDescription,
    );
    final id = await _db.insertReminder(model.toMap());

    if (reminder.isActive && reminder.daysOfWeek.isNotEmpty) {
      _scheduleNotification(
        id: id,
        medicineName: reminder.medicineName,
        doseDescription: reminder.doseDescription,
        time: reminder.time,
        daysOfWeek: reminder.daysOfWeek,
      );
    }
    return id;
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel(
      id: reminder.id,
      medicineName: reminder.medicineName,
      time: reminder.time,
      daysOfWeek: reminder.daysOfWeek,
      isActive: reminder.isActive,
      doseDescription: reminder.doseDescription,
    );
    await _db.updateReminder(model.toMap());

    if (reminder.id != null) {
      await _notifications.cancelReminderNotifications(reminder.id!);
      if (reminder.isActive && reminder.daysOfWeek.isNotEmpty) {
        _scheduleNotification(
          id: reminder.id!,
          medicineName: reminder.medicineName,
          doseDescription: reminder.doseDescription,
          time: reminder.time,
          daysOfWeek: reminder.daysOfWeek,
        );
      }
    }
  }

  @override
  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
    await _notifications.cancelReminderNotifications(id);
  }

  @override
  Future<void> toggleReminder(int id, bool isActive) async {
    final rows = await _db.getReminders();
    final row = rows.firstWhere(
      (r) => r['id'] == id,
      orElse: () => {},
    );
    if (row.isEmpty) return;

    final model = ReminderModel.fromMap(row);
    final updated = model.copyWith(isActive: isActive);
    await _db.updateReminder(updated.toMap());

    if (!isActive) {
      await _notifications.cancelReminderNotifications(id);
    } else if (model.daysOfWeek.isNotEmpty) {
      _scheduleNotification(
        id: id,
        medicineName: model.medicineName,
        doseDescription: model.doseDescription,
        time: model.time,
        daysOfWeek: model.daysOfWeek,
      );
    }
  }

  void _scheduleNotification({
    required int id,
    required String medicineName,
    required String doseDescription,
    required String time,
    required List<int> daysOfWeek,
  }) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    _notifications
        .scheduleWeeklyNotification(
          reminderId: id,
          title: '💊 ওষুধ খাওয়ার সময়!',
          body: doseDescription.isNotEmpty
              ? '$medicineName — $doseDescription'
              : medicineName,
          hour: hour,
          minute: minute,
          daysOfWeek: daysOfWeek,
        )
        .catchError(
          (e) => debugPrint('Notification schedule failed: $e'),
        );
  }
}
