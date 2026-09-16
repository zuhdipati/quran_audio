import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_month_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';
import 'package:quran_audio/features/hijri/domain/usecases/convert_to_hijri.dart';
import 'package:quran_audio/features/hijri/domain/usecases/get_hijri_month.dart';
import 'package:quran_audio/features/hijri/domain/usecases/get_upcoming_events.dart';

part 'hijri_event.dart';
part 'hijri_state.dart';

class HijriBloc extends Bloc<HijriEvent, HijriState> {
  final ConvertToHijri convertToHijri;
  final GetHijriMonth getHijriMonth;
  final GetUpcomingEvents getUpcomingEvents;

  HijriBloc({
    required this.convertToHijri,
    required this.getHijriMonth,
    required this.getUpcomingEvents,
  }) : super(const HijriState()) {
    on<HijriStarted>(_onStarted);
    on<HijriMonthChanged>(_onMonthChanged);
  }

  Future<void> _onStarted(HijriStarted event, Emitter<HijriState> emit) async {
    emit(state.copyWith(status: HijriStatus.loading));
    final today = convertToHijri(event.today);

    final upcoming = await getUpcomingEvents(event.today);
    final monthResult = await getHijriMonth(today.year, today.month);

    monthResult.fold(
      (failure) => emit(
        state.copyWith(status: HijriStatus.error, message: failure.message),
      ),
      (month) => emit(
        HijriState(
          status: HijriStatus.loaded,
          today: today,
          todayGregorian: event.today,
          month: month,
          upcomingEvents: upcoming.getOrElse(() => const []),
        ),
      ),
    );
  }

  Future<void> _onMonthChanged(
    HijriMonthChanged event,
    Emitter<HijriState> emit,
  ) async {
    final current = state.month;
    if (current == null) return;

    final index = current.year * 12 + (current.month - 1) + event.offset;
    final year = index ~/ 12;
    final month = index % 12 + 1;

    final result = await getHijriMonth(year, month);
    result.fold(
      (failure) => emit(state.copyWith(message: failure.message)),
      (month) => emit(state.copyWith(month: month)),
    );
  }
}
