import 'package:equatable/equatable.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/generic_alternative.dart';

class Medicine extends Equatable {
  final int? id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String indications;
  final String sideEffects;
  final String dosage;
  final String instructions;
  final String price;
  final List<GenericAlternative> genericAlternatives;

  const Medicine({
    this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.indications,
    required this.sideEffects,
    required this.dosage,
    required this.instructions,
    required this.price,
    required this.genericAlternatives,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        manufacturer,
        indications,
        sideEffects,
        dosage,
        instructions,
        price,
        genericAlternatives,
      ];
}
