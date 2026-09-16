part of 'salah_bloc.dart';

sealed class SalahState extends Equatable {
  const SalahState();

  @override
  List<Object?> get props => [];
}

final class SalahInitial extends SalahState {}

final class SalahLoading extends SalahState {}

final class SalahLoaded extends SalahState {
  final SalahGuideEntity guide;

  const SalahLoaded(this.guide);

  @override
  List<Object?> get props => [guide];
}

final class SalahError extends SalahState {
  final String message;

  const SalahError(this.message);

  @override
  List<Object?> get props => [message];
}
