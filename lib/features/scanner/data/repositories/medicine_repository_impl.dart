import 'package:medicine_guide_ai/core/errors/failures.dart';
import 'package:medicine_guide_ai/core/services/ocr_service.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_local_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/data/datasources/medicine_remote_datasource.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:medicine_guide_ai/features/scanner/domain/repositories/medicine_repository.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final OcrService _ocrService;
  final MedicineLocalDataSource _localDataSource;
  final MedicineRemoteDataSource _remoteDataSource;

  MedicineRepositoryImpl({
    required OcrService ocrService,
    required MedicineLocalDataSource localDataSource,
    required MedicineRemoteDataSource remoteDataSource,
  })  : _ocrService = ocrService,
        _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<(Failure?, Medicine?)> getMedicineDetailsFromImage(String imagePath) async {
    try {
      final ocrText = await _ocrService.recognizeText(imagePath);
      if (ocrText.trim().isEmpty) {
        return (const ServerFailure("ছবি থেকে কোনো লেখা পড়া যায়নি।"), null);
      }

      final cachedMedicine = await _localDataSource.getCachedMedicineByOcrText(ocrText);
      if (cachedMedicine != null) {
        await _localDataSource.saveScanLog(cachedMedicine.name, true);
        return (null, cachedMedicine);
      }

      final remoteMedicine = await _remoteDataSource.fetchMedicineDetails(ocrText);
      if (remoteMedicine == null) {
        return (const ServerFailure("ওষুধের তথ্য পাওয়া যায়নি। অনুগ্রহ করে আবার চেষ্টা করুন।"), null);
      }

      await _localDataSource.cacheMedicine(remoteMedicine);
      await _localDataSource.saveScanLog(remoteMedicine.name, false);

      return (null, remoteMedicine);
    } catch (e) {
      return (ServerFailure("ত্রুটি ঘটেছে: ${e.toString()}"), null);
    }
  }
}
