import 'dart:convert';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/history/domain/entities/history_entry.dart';
import 'package:medicine_guide_ai/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final DatabaseHelper _dbHelper;

  HistoryRepositoryImpl(this._dbHelper);

  @override
  Future<List<HistoryEntry>> getHistory() async {
    final rows = await _dbHelper.getHistory();
    return rows.map((row) {
      List<PrescriptionMedicine>? medicines;
      final jsonStr = row['prescriptionMedicinesJson'] as String?;
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final list = jsonDecode(jsonStr) as List;
          medicines = list.map((item) {
            final map = item as Map<String, dynamic>;
            return PrescriptionMedicine(
              name: map['name'] as String? ?? '',
              purpose: map['purpose'] as String? ?? '',
              dosage: map['dosage'] as String? ?? '',
              duration: map['duration'] as String? ?? '',
              genericName: map['genericName'] as String? ?? '',
              manufacturer: map['manufacturer'] as String? ?? '',
              sideEffects: map['sideEffects'] as String? ?? '',
              price: map['price'] as String? ?? '',
              genericAlternativesJson: map['genericAlternativesJson'] as String? ?? '[]',
            );
          }).toList();
        } catch (_) {}
      }

      return HistoryEntry(
        id: row['id'] as int?,
        medicineName: row['medicineName'] as String? ?? '',
        scannedAt: DateTime.tryParse(row['scannedAt'] as String? ?? '') ?? DateTime.now(),
        isOffline: (row['isOffline'] as int? ?? 0) == 1,
        imagePath: row['imagePath'] as String?,
        prescriptionMedicines: medicines,
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
