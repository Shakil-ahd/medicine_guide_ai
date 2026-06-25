import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class TabChanged extends NavigationEvent {
  final int index;

  const TabChanged(this.index);

  @override
  List<Object?> get props => [index];
}

class NavigationState extends Equatable {
  final int currentIndex;

  const NavigationState(this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(0)) {
    on<TabChanged>((event, emit) {
      emit(NavigationState(event.index));
    });
  }
}
