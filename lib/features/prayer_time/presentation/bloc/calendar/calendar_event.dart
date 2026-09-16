part of 'calendar_bloc.dart';

sealed class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class CalendarStarted extends CalendarEvent {
  final LocationEntity location;
  final DateTime initialDate;

  const CalendarStarted({required this.location, required this.initialDate});

  @override
  List<Object?> get props => [location, initialDate];
}

class CalendarMonthChanged extends CalendarEvent {
  final int offset;

  const CalendarMonthChanged(this.offset);

  @override
  List<Object?> get props => [offset];
}

class CalendarDaySelected extends CalendarEvent {
  final DateTime date;

  const CalendarDaySelected(this.date);

  @override
  List<Object?> get props => [date];
}
