part of 'prayer_time_bloc.dart';

sealed class PrayerTimeEvent extends Equatable {
  const PrayerTimeEvent();

  @override
  List<Object?> get props => [];
}

class PrayerTimesRequested extends PrayerTimeEvent {
  final bool refreshLocation;

  const PrayerTimesRequested({this.refreshLocation = false});

  @override
  List<Object?> get props => [refreshLocation];
}

class PrayerClockTicked extends PrayerTimeEvent {}
