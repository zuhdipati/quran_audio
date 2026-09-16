part of 'tasbeeh_bloc.dart';

enum TasbeehStatus { initial, loading, loaded, error }

class TasbeehState extends Equatable {
  final TasbeehStatus status;
  final List<DzikirEntity> dzikirList;
  final int selectedIndex;
  final Map<String, int> counts;
  final String? message;

  const TasbeehState({
    this.status = TasbeehStatus.initial,
    this.dzikirList = const [],
    this.selectedIndex = 0,
    this.counts = const {},
    this.message,
  });

  DzikirEntity? get current =>
      dzikirList.isEmpty ? null : dzikirList[selectedIndex];

  int get count => current == null ? 0 : (counts[current!.id] ?? 0);

  int get completedRounds => current == null ? 0 : count ~/ current!.target;

  /// Beads counted in the current round, 0..target.
  int get roundProgress {
    final dzikir = current;
    if (dzikir == null || count == 0) return 0;
    final remainder = count % dzikir.target;
    return remainder == 0 ? dzikir.target : remainder;
  }

  TasbeehState copyWith({
    TasbeehStatus? status,
    List<DzikirEntity>? dzikirList,
    int? selectedIndex,
    Map<String, int>? counts,
    String? message,
  }) {
    return TasbeehState(
      status: status ?? this.status,
      dzikirList: dzikirList ?? this.dzikirList,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      counts: counts ?? this.counts,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dzikirList,
    selectedIndex,
    counts,
    message,
  ];
}
