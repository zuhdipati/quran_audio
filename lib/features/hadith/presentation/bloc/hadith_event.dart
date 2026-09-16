part of 'hadith_bloc.dart';

sealed class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

class HadithsRequested extends HadithEvent {}

class HadithSearchChanged extends HadithEvent {
  final String query;

  const HadithSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
