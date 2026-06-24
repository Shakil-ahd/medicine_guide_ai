import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<Reminder> reminders;
  ReminderLoaded(this.reminders);
}

class ReminderError extends ReminderState {
  final String message;
  ReminderError(this.message);
}
