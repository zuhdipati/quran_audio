import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_prayer_schedules.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetPrayerSchedules getPrayerSchedules;

  CalendarBloc({required this.getPrayerSchedules})
    : super(const CalendarState()) {
    on<CalendarStarted>(_onStarted);
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarDaySelected>(_onDaySelected);
  }

  void _onStarted(CalendarStarted event, Emitter<CalendarState> emit) {
    final selected = _dateOnly(event.initialDate);
    _loadMonth(
      emit,
      location: event.location,
      month: DateTime(selected.year, selected.month),
      selectedDate: selected,
    );
  }

  void _onMonthChanged(
    CalendarMonthChanged event,
    Emitter<CalendarState> emit,
  ) {
    final location = state.location;
    final current = state.month;
    if (location == null || current == null) return;

    final month = DateTime(current.year, current.month + event.offset);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final previousDay = state.selectedDate?.day ?? 1;
    final selected = DateTime(
      month.year,
      month.month,
      previousDay > daysInMonth ? daysInMonth : previousDay,
    );
    _loadMonth(emit, location: location, month: month, selectedDate: selected);
  }

  void _onDaySelected(CalendarDaySelected event, Emitter<CalendarState> emit) {
    emit(state.copyWith(selectedDate: _dateOnly(event.date)));
  }

  void _loadMonth(
    Emitter<CalendarState> emit, {
    required LocationEntity location,
    required DateTime month,
    required DateTime selectedDate,
  }) {
    final days = DateTime(month.year, month.month + 1, 0).day;
    final result = getPrayerSchedules(location, month, days: days);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CalendarStatus.error,
          location: location,
          month: month,
          message: failure.message,
        ),
      ),
      (schedules) => emit(
        CalendarState(
          status: CalendarStatus.loaded,
          location: location,
          month: month,
          schedules: schedules,
          selectedDate: selectedDate,
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
