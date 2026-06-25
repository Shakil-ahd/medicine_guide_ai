import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/gemini_service.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_event.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final GeminiService _geminiService;
  bool _isCancelled = false;

  PrescriptionBloc(this._geminiService) : super(PrescriptionInitial()) {
    on<PrescriptionScanRequested>(_onScanRequested);
    on<PrescriptionScanCancelRequested>(_onCancelRequested);
  }

  void _onCancelRequested(
    PrescriptionScanCancelRequested event,
    Emitter<PrescriptionState> emit,
  ) {
    _isCancelled = true;
    emit(PrescriptionInitial());
  }

  Future<void> _onScanRequested(
    PrescriptionScanRequested event,
    Emitter<PrescriptionState> emit,
  ) async {
    _isCancelled = false;
    emit(PrescriptionLoading());
    try {
      final result = await _geminiService.parsePrescription(event.imagePath);
      if (_isCancelled) return;

      if (result == null || result.isEmpty) {
        emit(PrescriptionError(
          'প্রেসক্রিপশন পড়া যায়নি।\n'
          'API কোটা শেষ হয়ে থাকতে পারে — কিছুক্ষণ পর আবার চেষ্টা করুন।',
        ));
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

      if (_isCancelled) return;

      // Save medicines to the local medicines and history tables
      final dbHelper = DatabaseHelper.instance;
      for (final med in medicines) {
        if (med.name.trim().isNotEmpty) {
          await dbHelper.insertMedicine({
            'name': med.name,
            'genericName': 'প্রেসক্রিপশন ওষুধ',
            'manufacturer': 'প্রেসক্রিপশন থেকে সংগৃহীত',
            'indications': med.purpose,
            'sideEffects': 'কোনো পার্শ্বপ্রতিক্রিয়া তথ্য নেই।',
            'dosage': med.dosage,
            'instructions': med.duration,
            'price': 'N/A',
            'genericAlternativesJson': '[]',
          });

          await dbHelper.insertHistory({
            'medicineName': med.name,
            'scannedAt': DateTime.now().toIso8601String(),
            'isOffline': 0,
          });
        }
      }

      emit(PrescriptionLoaded(medicines));
    } catch (e) {
      if (_isCancelled) return;
      final msg = e.toString().toLowerCase();
      if (msg.contains('quota') || msg.contains('429')) {
        emit(PrescriptionError(
          'API কোটা শেষ হয়ে গেছে।\nকিছুক্ষণ পর আবার চেষ্টা করুন।',
        ));
      } else {
        emit(PrescriptionError('ত্রুটি: ${e.toString()}'));
      }
    }
  }
}
