part of 'hadith_bloc.dart';

sealed class HadithState extends Equatable {
  const HadithState();

  @override
  List<Object?> get props => [];
}

final class HadithInitial extends HadithState {}

final class HadithLoading extends HadithState {}

final class HadithLoaded extends HadithState {
  final HadithCollectionEntity collection;
  final List<HadithEntity> filtered;

  const HadithLoaded({required this.collection, required this.filtered});

  @override
  List<Object?> get props => [collection, filtered];
}

final class HadithError extends HadithState {
  final String message;

  const HadithError(this.message);

  @override
  List<Object?> get props => [message];
}
