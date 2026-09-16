part of 'calendar_bloc.dart';

enum CalendarStatus { initial, loaded, error }

class CalendarState extends Equatable {
  final CalendarStatus status;
  final LocationEntity? location;
  final DateTime? month;
  final List<PrayerScheduleEntity> schedules;
  final DateTime? selectedDate;
  final String? message;

  const CalendarState({
    this.status = CalendarStatus.initial,
    this.location,
    this.month,
    this.schedules = const [],
    this.selectedDate,
    this.message,
  });

  PrayerScheduleEntity? get selectedSchedule {
    final selected = selectedDate;
    if (selected == null) return null;
    for (final schedule in schedules) {
      if (schedule.date == selected) return schedule;
    }
    return null;
  }

  CalendarState copyWith({
    CalendarStatus? status,
    LocationEntity? location,
    DateTime? month,
    List<PrayerScheduleEntity>? schedules,
    DateTime? selectedDate,
    String? message,
  }) {
    return CalendarState(
      status: status ?? this.status,
      location: location ?? this.location,
      month: month ?? this.month,
      schedules: schedules ?? this.schedules,
      selectedDate: selectedDate ?? this.selectedDate,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    location,
    month,
    schedules,
    selectedDate,
    message,
  ];
}
