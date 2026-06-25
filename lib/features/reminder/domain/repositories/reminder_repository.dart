import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getReminders();
  Future<int> addReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  Future<void> deleteReminder(int id);
  Future<void> toggleReminder(int id, bool isActive);
}
