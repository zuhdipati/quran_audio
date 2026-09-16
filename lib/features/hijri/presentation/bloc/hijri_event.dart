part of 'hijri_bloc.dart';

sealed class HijriEvent extends Equatable {
  const HijriEvent();

  @override
  List<Object?> get props => [];
}

class HijriStarted extends HijriEvent {
  final DateTime today;

  const HijriStarted(this.today);

  @override
  List<Object?> get props => [today];
}

class HijriMonthChanged extends HijriEvent {
  final int offset;

  const HijriMonthChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}
