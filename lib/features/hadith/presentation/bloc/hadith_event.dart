part of 'hadith_bloc.dart';

sealed class HadithEvent extends Equatable {
  const HadithEvent();

  @override
  List<Object?> get props => [];
}

/// Load the narrator catalogue and open the first collection.
final class HadithsRequested extends HadithEvent {
  const HadithsRequested();
}

final class HadithCollectionSelected extends HadithEvent {
  final HadithCollectionEntity collection;

  const HadithCollectionSelected(this.collection);

  @override
  List<Object?> get props => [collection];
}

/// Show page [page] (1-based) of whatever is on screen: the collection, or
/// the search results.
final class HadithPageRequested extends HadithEvent {
  final int page;

  const HadithPageRequested(this.page);

  @override
  List<Object?> get props => [page];
}

/// The search field changed; debounced in the bloc.
final class HadithSearchChanged extends HadithEvent {
  final String query;

  const HadithSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class HadithSearchScopeChanged extends HadithEvent {
  final bool searchAll;

  const HadithSearchScopeChanged({required this.searchAll});

  @override
  List<Object?> get props => [searchAll];
}
