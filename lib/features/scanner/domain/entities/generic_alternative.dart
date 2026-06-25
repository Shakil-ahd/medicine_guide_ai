import 'package:equatable/equatable.dart';

class GenericAlternative extends Equatable {
  final String name;
  final String manufacturer;
  final String price;

  const GenericAlternative({
    required this.name,
    required this.manufacturer,
    required this.price,
  });

  @override
  List<Object?> get props => [name, manufacturer, price];
}
