import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_location.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_prayer_schedules.dart';

part 'prayer_time_event.dart';
part 'prayer_time_state.dart';

class PrayerTimeBloc extends Bloc<PrayerTimeEvent, PrayerTimeState> {
  final GetLocation getLocation;
  final GetPrayerSchedules getPrayerSchedules;
  final DateTime Function() clock;
  final Duration tickInterval;

  Timer? _ticker;

  PrayerTimeBloc({
    required this.getLocation,
    required this.getPrayerSchedules,
    DateTime Function()? clock,
    this.tickInterval = const Duration(seconds: 30),
  }) : clock = clock ?? DateTime.now,
       super(const PrayerTimeState()) {
    on<PrayerTimesRequested>(_onRequested);
    on<PrayerClockTicked>(_onTicked);
  }

  Future<void> _onRequested(
    PrayerTimesRequested event,
    Emitter<PrayerTimeState> emit,
  ) async {
    emit(state.copyWith(status: PrayerTimeStatus.loading, clearMessage: true));

    final result = await getLocation(refresh: event.refreshLocation);
    await result.fold((failure) async {
      // keep showing the previous schedule when a refresh fails
      if (state.location != null) {
        emit(
          state.copyWith(
            status: PrayerTimeStatus.loaded,
            message: failure.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PrayerTimeStatus.error,
            message: failure.message,
          ),
        );
      }
    }, (location) async => _emitSchedules(emit, location));

    _ticker ??= Timer.periodic(tickInterval, (_) => add(PrayerClockTicked()));
  }

  void _onTicked(PrayerClockTicked event, Emitter<PrayerTimeState> emit) {
    final location = state.location;
    if (location == null) return;

    final now = clock();
    final today = state.today;
    if (today == null || !_isSameDay(today.date, now)) {
      _emitSchedules(emit, location);
    } else {
      emit(state.copyWith(now: now));
    }
  }

  void _emitSchedules(Emitter<PrayerTimeState> emit, LocationEntity location) {
    final now = clock();
    final result = getPrayerSchedules(location, now, days: 2);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PrayerTimeStatus.error,
          location: location,
          message: failure.message,
        ),
      ),
      (schedules) => emit(
        state.copyWith(
          status: PrayerTimeStatus.loaded,
          location: location,
          today: schedules.first,
          tomorrow: schedules.last,
          now: now,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> close() {
    _ticker?.cancel();
    return super.close();
  }
}
