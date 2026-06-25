import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/features/history/domain/repositories/history_repository.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_event.dart';
import 'package:medicine_guide_ai/features/history/presentation/bloc/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;

  HistoryBloc(this._repository) : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteHistoryItemEvent>(_onDeleteHistoryItem);
    on<ClearHistoryEvent>(_onClearHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final historyList = await _repository.getHistory();
      emit(HistoryLoaded(historyList));
    } catch (e) {
      emit(const HistoryError('মেডিকেল হিস্ট্রি লোড করতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItemEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.deleteHistoryItem(event.id);
      final historyList = await _repository.getHistory();
      emit(HistoryLoaded(historyList));
    } catch (_) {
      emit(const HistoryError('আইটেম মুছতে সমস্যা হয়েছে।'));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.clearHistory();
      emit(const HistoryLoaded([]));
    } catch (_) {
      emit(const HistoryError('হিস্ট্রি মুছতে সমস্যা হয়েছে।'));
    }
  }
}
