import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_event.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final GeminiService _geminiService;

  PrescriptionBloc(this._geminiService) : super(PrescriptionInitial()) {
    on<PrescriptionScanRequested>(_onScanRequested);
  }

  Future<void> _onScanRequested(
    PrescriptionScanRequested event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(PrescriptionLoading());
    final result = await _geminiService.parsePrescription(event.imagePath);
    if (result == null || result.isEmpty) {
      emit(PrescriptionError('প্রেসক্রিপশন পড়তে সমস্যা হয়েছে। আবার চেষ্টা করুন।'));
      return;
    }
    final medicines = result.map((item) {
      final map = item as Map<String, dynamic>;
      return PrescriptionMedicine(
        name: map['name'] as String? ?? '',
        purpose: map['purpose'] as String? ?? '',
        dosage: map['dosage'] as String? ?? '',
        duration: map['duration'] as String? ?? '',
      );
    }).toList();
    emit(PrescriptionLoaded(medicines));
  }
}
