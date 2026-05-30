part of 'edition_bloc.dart';

sealed class EditionState extends Equatable {
  const EditionState();
  
  @override
  List<Object?> get props => [];
}

final class EditionInitial extends EditionState {}

final class EditionLoading extends EditionState {}

final class EditionLoaded extends EditionState {
  final List<EditionEntity> allEditions;
  final List<EditionEntity> filteredEditions;

  const EditionLoaded({
    required this.allEditions,
    required this.filteredEditions,
  });

  @override
  List<Object> get props => [allEditions, filteredEditions];
}

final class EditionError extends EditionState {
  final String message;

  const EditionError(this.message);

  @override
  List<Object> get props => [message];
}
