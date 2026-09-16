part of 'dua_bloc.dart';

sealed class DuaEvent extends Equatable {
  const DuaEvent();

  @override
  List<Object?> get props => [];
}

class DuasRequested extends DuaEvent {}

class DuaSearchChanged extends DuaEvent {
  final String query;

  const DuaSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class DuaGroupSelected extends DuaEvent {
  /// Null shows every group.
  final String? group;

  const DuaGroupSelected(this.group);

  @override
  List<Object?> get props => [group];
}
