import 'package:equatable/equatable.dart';

class HistoryEntry extends Equatable {
  final int? id;
  final String medicineName;
  final DateTime scannedAt;
  final bool isOffline;

  const HistoryEntry({
    this.id,
    required this.medicineName,
    required this.scannedAt,
    required this.isOffline,
  });

  @override
  List<Object?> get props => [id, medicineName, scannedAt, isOffline];
}
