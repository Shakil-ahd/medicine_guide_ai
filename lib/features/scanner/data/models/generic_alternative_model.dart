import 'package:medicine_guide_ai/features/scanner/domain/entities/generic_alternative.dart';

class GenericAlternativeModel extends GenericAlternative {
  const GenericAlternativeModel({
    required super.name,
    required super.manufacturer,
    required super.price,
  });

  factory GenericAlternativeModel.fromJson(Map<String, dynamic> json) {
    return GenericAlternativeModel(
      name: json['name'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      price: json['price'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'manufacturer': manufacturer,
      'price': price,
    };
  }
}
