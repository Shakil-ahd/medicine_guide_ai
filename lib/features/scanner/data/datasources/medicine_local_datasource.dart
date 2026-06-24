import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';

abstract class MedicineLocalDataSource {
  Future<void> cacheMedicine(MedicineModel medicine);
  Future<MedicineModel?> getCachedMedicineByOcrText(String ocrText);
  Future<void> saveScanLog(String medicineName, bool isOffline);
}

class MedicineLocalDataSourceImpl implements MedicineLocalDataSource {
  final DatabaseHelper _dbHelper;

  MedicineLocalDataSourceImpl(this._dbHelper);

  @override
  Future<void> cacheMedicine(MedicineModel medicine) async {
    await _dbHelper.insertMedicine(medicine.toDbMap());
  }

  @override
  Future<MedicineModel?> getCachedMedicineByOcrText(String ocrText) async {
    final db = await _dbHelper.database;
    final results = await db.query('medicines');
    final cleanOcr = ocrText.toLowerCase();

    for (final row in results) {
      final name = (row['name'] as String).toLowerCase();
      if (cleanOcr.contains(name) && name.isNotEmpty) {
        return MedicineModel.fromDbMap(row);
      }
    }
    return null;
  }

  @override
  Future<void> saveScanLog(String medicineName, bool isOffline) async {
    await _dbHelper.insertHistory({
      'medicineName': medicineName,
      'scannedAt': DateTime.now().toIso8601String(),
      'isOffline': isOffline ? 1 : 0,
    });
  }
}
