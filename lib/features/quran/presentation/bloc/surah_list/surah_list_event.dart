part of 'surah_list_bloc.dart';

abstract class SurahListEvent extends Equatable {
  const SurahListEvent();

  @override
  List<Object?> get props => [];
}

class FetchSurahs extends SurahListEvent {
  final EditionEntity edition;

  const FetchSurahs(this.edition);

  @override
  List<Object> get props => [edition];
}

class SearchSurahs extends SurahListEvent {
  final String query;

  const SearchSurahs(this.query);

  @override
  List<Object> get props => [query];
}
