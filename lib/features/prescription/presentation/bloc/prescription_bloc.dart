import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicine_guide_ai/core/services/database_helper.dart';
import 'package:medicine_guide_ai/core/services/ai_scanner_service.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_event.dart';
import 'package:medicine_guide_ai/features/prescription/presentation/bloc/prescription_state.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final AiScannerService _aiScannerService;
  bool _isCancelled = false;

  PrescriptionBloc(this._aiScannerService) : super(PrescriptionInitial()) {
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
      final result = await _aiScannerService.parsePrescription(event.imagePath);
      if (_isCancelled) return;

      if (result == null || result.isEmpty) {
        emit(PrescriptionError(
          'প্রেসক্রিপশন পড়া যায়নি।\n'
          'API কোটা শেষ হয়ে থাকতে পারে — কিছুক্ষণ পর আবার চেষ্টা করুন।',
        ));
        return;
      }

      // Check if there is a validation error in the response
      if (result.isNotEmpty &&
          result.first is Map &&
          (result.first as Map).containsKey('error')) {
        emit(PrescriptionError((result.first as Map)['error'] as String));
        return;
      }
      final medicines = result.map((item) {
        final map = item as Map<String, dynamic>;
        final alternativesList = map['genericAlternatives'] as List? ?? [];
        return PrescriptionMedicine(
          name: map['name'] as String? ?? '',
          purpose: map['purpose'] as String? ?? '',
          dosage: map['dosage'] as String? ?? '',
          duration: map['duration'] as String? ?? '',
          genericName: map['genericName'] as String? ?? 'প্রেসক্রিপশন ওষুধ',
          manufacturer: map['manufacturer'] as String? ?? 'প্রেসক্রিপশন থেকে সংগৃহীত',
          sideEffects: map['sideEffects'] as String? ?? 'কোনো পার্শ্বপ্রতিক্রিয়া তথ্য নেই।',
          price: map['price'] as String? ?? 'N/A',
          genericAlternativesJson: jsonEncode(alternativesList),
        );
      }).toList();

      if (_isCancelled) return;

      final dbHelper = DatabaseHelper.instance;
      for (final med in medicines) {
        if (med.name.trim().isNotEmpty) {
          final existing = await dbHelper.getMedicineByName(med.name);
          if (existing == null) {
            await dbHelper.insertMedicine({
              'name': med.name,
              'genericName': med.genericName,
              'manufacturer': med.manufacturer,
              'indications': med.purpose,
              'sideEffects': med.sideEffects,
              'dosage': med.dosage,
              'instructions': med.duration,
              'price': med.price,
              'genericAlternativesJson': med.genericAlternativesJson,
            });
          }
        }
      }

      final medicinesJson = jsonEncode(medicines.map((m) => {
        'name': m.name,
        'purpose': m.purpose,
        'dosage': m.dosage,
        'duration': m.duration,
        'genericName': m.genericName,
        'manufacturer': m.manufacturer,
        'sideEffects': m.sideEffects,
        'price': m.price,
        'genericAlternativesJson': m.genericAlternativesJson,
      }).toList());

      await dbHelper.insertHistory({
        'medicineName': 'প্রেসক্রিপশন স্ক্যান',
        'scannedAt': DateTime.now().toIso8601String(),
        'isOffline': 0,
        'imagePath': event.imagePath,
        'prescriptionMedicinesJson': medicinesJson,
      });

      emit(PrescriptionLoaded(medicines));
    } catch (e) {
      if (_isCancelled) return;
      var errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      final msgLower = errorMsg.toLowerCase();
      if (msgLower.contains('quota') || msgLower.contains('429')) {
        emit(PrescriptionError(
          'API কোটা শেষ হয়ে গেছে।\nকিছুক্ষণ পর আবার চেষ্টা করুন।',
        ));
      } else {
        emit(PrescriptionError(errorMsg));
      }
    }
  }
}
