import 'dart:convert';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:medicine_guide_ai/features/scanner/data/models/generic_alternative_model.dart';

class MedicineModel extends Medicine {
  const MedicineModel({
    super.id,
    required super.name,
    required super.genericName,
    required super.manufacturer,
    required super.indications,
    required super.sideEffects,
    required super.dosage,
    required super.instructions,
    required super.price,
    required super.genericAlternatives,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    var alternativesList = json['genericAlternatives'] as List? ?? [];
    List<GenericAlternativeModel> alternatives = alternativesList
        .map((e) => GenericAlternativeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MedicineModel(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      indications: json['indications'] ?? '',
      sideEffects: json['sideEffects'] ?? '',
      dosage: json['dosage'] ?? '',
      instructions: json['instructions'] ?? '',
      price: json['price'] ?? '',
      genericAlternatives: alternatives,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'indications': indications,
      'sideEffects': sideEffects,
      'dosage': dosage,
      'instructions': instructions,
      'price': price,
      'genericAlternatives': genericAlternatives
          .map((e) => (e as GenericAlternativeModel).toJson())
          .toList(),
    };
  }

  factory MedicineModel.fromDbMap(Map<String, dynamic> map) {
    List<dynamic> alternativesJson = [];
    try {
      if (map['genericAlternativesJson'] != null) {
        alternativesJson = jsonDecode(map['genericAlternativesJson'] as String) as List;
      }
    } catch (_) {}

    List<GenericAlternativeModel> alternatives = alternativesJson
        .map((e) => GenericAlternativeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return MedicineModel(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      genericName: map['genericName'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      indications: map['indications'] ?? '',
      sideEffects: map['sideEffects'] ?? '',
      dosage: map['dosage'] ?? '',
      instructions: map['instructions'] ?? '',
      price: map['price'] ?? '',
      genericAlternatives: alternatives,
    );
  }

  Map<String, dynamic> toDbMap() {
    final alternativesJsonStr = jsonEncode(
      genericAlternatives
          .map((e) => {
                'name': e.name,
                'manufacturer': e.manufacturer,
                'price': e.price,
              })
          .toList(),
    );

    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'indications': indications,
      'sideEffects': sideEffects,
      'dosage': dosage,
      'instructions': instructions,
      'price': price,
      'genericAlternativesJson': alternativesJsonStr,
    };
  }
}
