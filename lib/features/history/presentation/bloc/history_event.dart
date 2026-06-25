import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {}

class DeleteHistoryItemEvent extends HistoryEvent {
  final int id;
  const DeleteHistoryItemEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearHistoryEvent extends HistoryEvent {}
