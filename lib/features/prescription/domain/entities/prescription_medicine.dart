import 'dart:convert';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/generic_alternative.dart';

class PrescriptionMedicine {
  final String name;
  final String purpose;
  final String dosage;
  final String duration;
  final String genericName;
  final String manufacturer;
  final String sideEffects;
  final String price;
  final String genericAlternativesJson;

  const PrescriptionMedicine({
    required this.name,
    required this.purpose,
    required this.dosage,
    required this.duration,
    this.genericName = '',
    this.manufacturer = '',
    this.sideEffects = '',
    this.price = '',
    this.genericAlternativesJson = '[]',
  });

  Medicine toMedicine() {
    List<GenericAlternative> alternatives = [];
    try {
      if (genericAlternativesJson.isNotEmpty) {
        final decoded = jsonDecode(genericAlternativesJson) as List;
        alternatives = decoded.map((item) {
          final map = item as Map<String, dynamic>;
          return GenericAlternative(
            name: map['name'] as String? ?? '',
            manufacturer: map['manufacturer'] as String? ?? '',
            price: map['price'] as String? ?? '',
          );
        }).toList();
      }
    } catch (_) {}

    return Medicine(
      name: name,
      genericName: genericName.isNotEmpty ? genericName : 'প্রেসক্রিপশন ওষুধ',
      manufacturer: manufacturer.isNotEmpty ? manufacturer : 'প্রেসক্রিপশন থেকে সংগৃহীত',
      indications: purpose.isNotEmpty ? purpose : 'প্রেসক্রিপশন উদ্দেশ্য',
      sideEffects: sideEffects.isNotEmpty ? sideEffects : 'কোনো পার্শ্বপ্রতিক্রিয়া তথ্য নেই।',
      dosage: dosage,
      instructions: duration,
      price: price.isNotEmpty ? price : 'N/A',
      genericAlternatives: alternatives,
    );
  }
}

