part of 'daily_dua_bloc.dart';

sealed class DailyDuaEvent extends Equatable {
  const DailyDuaEvent();

  @override
  List<Object?> get props => [];
}

class DailyDuaRequested extends DailyDuaEvent {
  final DateTime date;

  const DailyDuaRequested(this.date);

  @override
  List<Object?> get props => [date];
}
