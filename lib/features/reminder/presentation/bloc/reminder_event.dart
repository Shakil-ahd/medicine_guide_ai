import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';

abstract class ReminderEvent {}

class LoadRemindersEvent extends ReminderEvent {}

class AddReminderEvent extends ReminderEvent {
  final Reminder reminder;
  AddReminderEvent(this.reminder);
}

class UpdateReminderEvent extends ReminderEvent {
  final Reminder reminder;
  UpdateReminderEvent(this.reminder);
}

class DeleteReminderEvent extends ReminderEvent {
  final int id;
  DeleteReminderEvent(this.id);
}

class ToggleReminderEvent extends ReminderEvent {
  final int id;
  final bool isActive;
  ToggleReminderEvent(this.id, this.isActive);
}
