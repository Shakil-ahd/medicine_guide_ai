import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<MedicineModel?> fetchMedicineDetails(String imagePath, String scannedText);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final GeminiService _geminiService;

  MedicineRemoteDataSourceImpl(this._geminiService);

  @override
  Future<MedicineModel?> fetchMedicineDetails(String imagePath, String scannedText) async {
    final data = await _geminiService.fetchMedicineDetails(imagePath, scannedText);
    if (data != null) {
      return MedicineModel.fromJson(data);
    }
    return null;
  }
}
