part of 'surah_list_bloc.dart';

abstract class SurahListState extends Equatable {
  const SurahListState();
  
  @override
  List<Object?> get props => [];
}

class SurahListInitial extends SurahListState {}

class SurahListLoading extends SurahListState {
  final EditionEntity? currentEdition;
  
  const SurahListLoading({this.currentEdition});
  
  @override
  List<Object?> get props => [currentEdition];
}

class SurahListLoaded extends SurahListState {
  final List<SurahEntity> allSurahs;
  final List<SurahEntity> filteredSurahs;
  final EditionEntity currentEdition;

  const SurahListLoaded({
    required this.allSurahs,
    required this.filteredSurahs,
    required this.currentEdition,
  });

  @override
  List<Object> get props => [allSurahs, filteredSurahs, currentEdition];
}

class SurahListError extends SurahListState {
  final String message;

  const SurahListError(this.message);

  @override
  List<Object> get props => [message];
}
