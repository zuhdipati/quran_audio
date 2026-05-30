part of 'qori_bloc.dart';

sealed class QoriState extends Equatable {
  const QoriState();

  @override
  List<Object> get props => [];
}

final class QoriInitial extends QoriState {}
