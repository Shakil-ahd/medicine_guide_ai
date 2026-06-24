import 'package:medicine_guide_ai/core/errors/failures.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';

abstract class MedicineRepository {
  Future<(Failure?, Medicine?)> getMedicineDetailsFromImage(String imagePath);
}
