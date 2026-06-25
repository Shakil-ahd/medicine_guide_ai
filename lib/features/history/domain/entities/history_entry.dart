import 'package:equatable/equatable.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final String medicineName;
  final DateTime scannedAt;
  final bool isOffline;
  final String? imagePath;
  final List<PrescriptionMedicine>? prescriptionMedicines;

  const HistoryEntry({
    this.id,
    required this.medicineName,
    required this.scannedAt,
    required this.isOffline,
    this.imagePath,
    this.prescriptionMedicines,
  });

  bool get isPrescription =>
      prescriptionMedicines != null && prescriptionMedicines!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        medicineName,
        scannedAt,
        isOffline,
        imagePath,
        prescriptionMedicines,
      ];
}
