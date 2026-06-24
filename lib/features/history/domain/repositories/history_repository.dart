import 'package:medicine_guide_ai/features/history/domain/entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getHistory();
  Future<void> deleteHistoryItem(int id);
  Future<void> clearHistory();
}
