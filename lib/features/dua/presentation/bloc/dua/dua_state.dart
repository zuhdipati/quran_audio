part of 'dua_bloc.dart';

enum DuaStatus { initial, loading, loaded, error }

class DuaState extends Equatable {
  final DuaStatus status;
  final List<DuaEntity> allDuas;
  final List<DuaEntity> filteredDuas;
  final List<String> groups;
  final String? selectedGroup;
  final String query;
  final String? message;

  const DuaState({
    this.status = DuaStatus.initial,
    this.allDuas = const [],
    this.filteredDuas = const [],
    this.groups = const [],
    this.selectedGroup,
    this.query = '',
    this.message,
  });

  DuaState copyWith({DuaStatus? status, String? message}) {
    return DuaState(
      status: status ?? this.status,
      allDuas: allDuas,
      filteredDuas: filteredDuas,
      groups: groups,
      selectedGroup: selectedGroup,
      query: query,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allDuas,
    filteredDuas,
    groups,
    selectedGroup,
    query,
    message,
  ];
}
