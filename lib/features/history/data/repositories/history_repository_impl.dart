import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/history/domain/entities/history_entry.dart';
import 'package:medicine_guide_ai/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final DatabaseHelper _dbHelper;

  HistoryRepositoryImpl(this._dbHelper);

  @override
  Future<List<HistoryEntry>> getHistory() async {
    final rows = await _dbHelper.getHistory();
    return rows.map((row) {
      return HistoryEntry(
        id: row['id'] as int?,
        medicineName: row['medicineName'] as String? ?? '',
        scannedAt: DateTime.tryParse(row['scannedAt'] as String? ?? '') ?? DateTime.now(),
        isOffline: (row['isOffline'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  @override
  Future<void> deleteHistoryItem(int id) async {
    await _dbHelper.deleteHistoryItem(id);
  }

  @override
  Future<void> clearHistory() async {
    await _dbHelper.clearHistory();
  }
}
