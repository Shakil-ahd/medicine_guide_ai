import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final int? id;
  final String medicineName;
  final String time;
  final List<int> daysOfWeek;
  final bool isActive;
  final String doseDescription;

  const Reminder({
    this.id,
    required this.medicineName,
    required this.time,
    required this.daysOfWeek,
    required this.isActive,
    required this.doseDescription,
  });

  @override
  List<Object?> get props => [
        id,
        medicineName,
        time,
        daysOfWeek,
        isActive,
        doseDescription,
      ];
}
