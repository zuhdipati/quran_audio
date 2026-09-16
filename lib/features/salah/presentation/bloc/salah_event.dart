part of 'salah_bloc.dart';

sealed class SalahEvent extends Equatable {
  const SalahEvent();

  @override
  List<Object?> get props => [];
}

class SalahGuideRequested extends SalahEvent {}
