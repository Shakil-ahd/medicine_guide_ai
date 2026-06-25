import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medicine_guide_ai/core/services/tts_service.dart';
import 'package:medicine_guide_ai/features/scanner/domain/entities/medicine.dart';
import 'package:medicine_guide_ai/features/scanner/domain/repositories/medicine_repository.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class ScanMedicineEvent extends MedicineEvent {
  final String imagePath;

  const ScanMedicineEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ReadMedicineTtsEvent extends MedicineEvent {
  final String text;

  const ReadMedicineTtsEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class StopMedicineTtsEvent extends MedicineEvent {}

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final Medicine medicine;

  const MedicineLoaded(this.medicine);

  @override
  List<Object?> get props => [medicine];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final MedicineRepository _repository;
  final TtsService _ttsService;

  MedicineBloc({
    required MedicineRepository repository,
    required TtsService ttsService,
  })  : _repository = repository,
        _ttsService = ttsService,
        super(MedicineInitial()) {
    on<ScanMedicineEvent>((event, emit) async {
      emit(MedicineLoading());
      final result = await _repository.getMedicineDetailsFromImage(event.imagePath);
      final failure = result.$1;
      final medicine = result.$2;

      if (failure != null) {
        emit(MedicineError(failure.message));
      } else if (medicine != null) {
        emit(MedicineLoaded(medicine));
      } else {
        emit(const MedicineError("ওষুধের তথ্য পাওয়া যায়নি।"));
      }
    });

    on<ReadMedicineTtsEvent>((event, emit) async {
      await _ttsService.speak(event.text);
    });

    on<StopMedicineTtsEvent>((event, emit) async {
      await _ttsService.stop();
    });
  }

  @override
  Future<void> close() {
    _ttsService.stop();
    return super.close();
  }
}
