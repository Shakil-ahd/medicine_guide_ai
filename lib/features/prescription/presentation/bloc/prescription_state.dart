import 'package:equatable/equatable.dart';
import 'package:medicine_guide_ai/features/prescription/domain/entities/prescription_medicine.dart';

abstract class PrescriptionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrescriptionInitial extends PrescriptionState {}

class PrescriptionLoading extends PrescriptionState {}

class PrescriptionLoaded extends PrescriptionState {
  final List<PrescriptionMedicine> medicines;

  PrescriptionLoaded(this.medicines);

  @override
  List<Object?> get props => [medicines];
}

class PrescriptionError extends PrescriptionState {
  final String message;

  PrescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
