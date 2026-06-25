import 'package:equatable/equatable.dart';

abstract class PrescriptionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrescriptionScanRequested extends PrescriptionEvent {
  final String imagePath;

  PrescriptionScanRequested(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class PrescriptionScanCancelRequested extends PrescriptionEvent {}
