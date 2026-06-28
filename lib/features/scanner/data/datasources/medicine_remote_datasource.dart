import 'package:medicine_guide_ai/core/services/ai_scanner_service.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<MedicineModel?> fetchMedicineDetails(String imagePath, String scannedText);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final AiScannerService _aiScannerService;

  MedicineRemoteDataSourceImpl(this._aiScannerService);

  @override
  Future<MedicineModel?> fetchMedicineDetails(String imagePath, String scannedText) async {
    final data = await _aiScannerService.fetchMedicineDetails(imagePath, scannedText);
    if (data != null) {
      return MedicineModel.fromJson(data);
    }
    return null;
  }
}
