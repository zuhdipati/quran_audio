part of 'tasbeeh_bloc.dart';

sealed class TasbeehEvent extends Equatable {
  const TasbeehEvent();

  @override
  List<Object?> get props => [];
}

class TasbeehStarted extends TasbeehEvent {}

class TasbeehDzikirSelected extends TasbeehEvent {
  final int index;

  const TasbeehDzikirSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class TasbeehIncremented extends TasbeehEvent {}

class TasbeehReset extends TasbeehEvent {}

/// Look at the date again, e.g. when the app returns to the foreground,
/// in case midnight passed while it was away.
class TasbeehDayChecked extends TasbeehEvent {}
