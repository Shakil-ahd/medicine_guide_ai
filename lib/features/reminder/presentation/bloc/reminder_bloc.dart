import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/features/reminder/domain/repositories/reminder_repository.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_event.dart';
import 'package:medicine_guide_ai/features/reminder/presentation/bloc/reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository _repository;

  ReminderBloc(this._repository) : super(ReminderInitial()) {
    on<LoadRemindersEvent>(_onLoad);
    on<AddReminderEvent>(_onAdd);
    on<UpdateReminderEvent>(_onUpdate);
    on<DeleteReminderEvent>(_onDelete);
    on<ToggleReminderEvent>(_onToggle);
  }

  Future<void> _onLoad(
    LoadRemindersEvent event,
    Emitter<ReminderState> emit,
  ) async {
    emit(ReminderLoading());
    try {
      final reminders = await _repository.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError('রিমাইন্ডার লোড করতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onAdd(
    AddReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.addReminder(event.reminder);
      final reminders = await _repository.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError('রিমাইন্ডার যোগ করতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onUpdate(
    UpdateReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.updateReminder(event.reminder);
      final reminders = await _repository.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError('রিমাইন্ডার আপডেট করতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onDelete(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.deleteReminder(event.id);
      final reminders = await _repository.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError('রিমাইন্ডার মুছতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onToggle(
    ToggleReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await _repository.toggleReminder(event.id, event.isActive);
      final reminders = await _repository.getReminders();
      emit(ReminderLoaded(reminders));
    } catch (e) {
      emit(ReminderError('রিমাইন্ডার আপডেট করতে সমস্যা হয়েছে।'));
    }
  }
}
