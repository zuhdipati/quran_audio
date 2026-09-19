import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/get_dzikir_list.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/tasbeeh_counts.dart';

part 'tasbeeh_event.dart';
part 'tasbeeh_state.dart';

class TasbeehBloc extends Bloc<TasbeehEvent, TasbeehState> {
  final GetDzikirList getDzikirList;
  final GetTasbeehCounts getTasbeehCounts;
  final SaveTasbeehCount saveTasbeehCount;
  final DateTime Function() clock;

  TasbeehBloc({
    required this.getDzikirList,
    required this.getTasbeehCounts,
    required this.saveTasbeehCount,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now,
       super(const TasbeehState()) {
    on<TasbeehStarted>(_onStarted);
    on<TasbeehDzikirSelected>(_onSelected);
    on<TasbeehIncremented>(_onIncremented);
    on<TasbeehReset>(_onReset);
    on<TasbeehDayChecked>((event, emit) => _startNewDayIfNeeded(emit));
  }

  Future<void> _onStarted(
    TasbeehStarted event,
    Emitter<TasbeehState> emit,
  ) async {
    emit(state.copyWith(status: TasbeehStatus.loading));
    final today = clock();
    final result = await getDzikirList();
    final counts = await getTasbeehCounts(today);
    result.fold(
      (failure) => emit(
        state.copyWith(status: TasbeehStatus.error, message: failure.message),
      ),
      (list) => emit(
        TasbeehState(
          status: TasbeehStatus.loaded,
          dzikirList: list,
          counts: counts,
          day: today,
        ),
      ),
    );
  }

  void _onSelected(TasbeehDzikirSelected event, Emitter<TasbeehState> emit) {
    if (event.index < 0 || event.index >= state.dzikirList.length) return;
    emit(state.copyWith(selectedIndex: event.index));
  }

  Future<void> _onIncremented(
    TasbeehIncremented event,
    Emitter<TasbeehState> emit,
  ) async {
    final dzikir = state.current;
    if (dzikir == null) return;
    _startNewDayIfNeeded(emit);
    final count = state.count + 1;
    emit(state.copyWith(counts: {...state.counts, dzikir.id: count}));
    await saveTasbeehCount(dzikir.id, count, state.day!);
  }

  Future<void> _onReset(TasbeehReset event, Emitter<TasbeehState> emit) async {
    final dzikir = state.current;
    if (dzikir == null) return;
    _startNewDayIfNeeded(emit);
    emit(state.copyWith(counts: {...state.counts, dzikir.id: 0}));
    await saveTasbeehCount(dzikir.id, 0, state.day!);
  }

  /// Counts belong to one calendar day. Instead of a timer waiting for
  /// midnight, the date is compared whenever the counter is next used: on a
  /// tap, or when the app comes back to the foreground. Storage needs no
  /// clearing, since other days' counts already read as empty.
  void _startNewDayIfNeeded(Emitter<TasbeehState> emit) {
    final day = state.day;
    final today = clock();
    if (day == null || DateTimeUtils.isSameDay(day, today)) return;
    emit(state.copyWith(counts: const {}, day: today));
  }
}
