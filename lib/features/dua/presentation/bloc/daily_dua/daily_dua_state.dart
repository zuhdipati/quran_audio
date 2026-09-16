part of 'daily_dua_bloc.dart';

sealed class DailyDuaState extends Equatable {
  const DailyDuaState();

  @override
  List<Object?> get props => [];
}

final class DailyDuaInitial extends DailyDuaState {}

final class DailyDuaLoading extends DailyDuaState {}

final class DailyDuaLoaded extends DailyDuaState {
  final DuaEntity dua;

  const DailyDuaLoaded(this.dua);

  @override
  List<Object?> get props => [dua];
}

final class DailyDuaError extends DailyDuaState {
  final String message;

  const DailyDuaError(this.message);

  @override
  List<Object?> get props => [message];
}
