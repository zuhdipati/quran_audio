part of 'edition_bloc.dart';

sealed class EditionEvent extends Equatable {
  const EditionEvent();

  @override
  List<Object> get props => [];
}

class GetEditions extends EditionEvent {}

class SearchEditions extends EditionEvent {
  final String query;

  const SearchEditions(this.query);

  @override
  List<Object> get props => [query];
}
