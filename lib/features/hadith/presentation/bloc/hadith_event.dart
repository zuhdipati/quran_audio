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

/// Pull the next chunk of the open collection.
final class HadithNextPageRequested extends HadithEvent {
  const HadithNextPageRequested();
}

final class HadithSearchChanged extends HadithEvent {
  final String query;

  const HadithSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
