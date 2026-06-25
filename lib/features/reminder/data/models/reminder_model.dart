import 'package:medicine_guide_ai/features/reminder/domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    super.id,
    required super.medicineName,
    required super.time,
    required super.daysOfWeek,
    required super.isActive,
    required super.doseDescription,
  });

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    final daysStr = map['daysOfWeek'] as String? ?? '';
    final days = daysStr.isEmpty
        ? <int>[]
        : daysStr.split(',').map((e) => int.tryParse(e.trim()) ?? 1).toList();

    return ReminderModel(
      id: map['id'] as int?,
      medicineName: map['medicineName'] as String? ?? '',
      time: map['time'] as String? ?? '08:00',
      daysOfWeek: days,
      isActive: (map['isActive'] as int? ?? 1) == 1,
      doseDescription: map['doseDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'medicineName': medicineName,
      'time': time,
      'daysOfWeek': daysOfWeek.join(','),
      'isActive': isActive ? 1 : 0,
      'doseDescription': doseDescription,
    };
  }

  ReminderModel copyWith({
    int? id,
    String? medicineName,
    String? time,
    List<int>? daysOfWeek,
    bool? isActive,
    String? doseDescription,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      doseDescription: doseDescription ?? this.doseDescription,
    );
  }
}
