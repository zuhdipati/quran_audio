part of 'prayer_time_bloc.dart';

enum PrayerTimeStatus { initial, loading, loaded, error }

class UpcomingPrayer extends Equatable {
  final PrayerName prayer;
  final DateTime time;

  const UpcomingPrayer(this.prayer, this.time);

  @override
  List<Object?> get props => [prayer, time];
}

class PrayerTimeState extends Equatable {
  final PrayerTimeStatus status;
  final LocationEntity? location;
  final PrayerScheduleEntity? today;
  final PrayerScheduleEntity? tomorrow;
  final DateTime? now;
  final String? message;

  const PrayerTimeState({
    this.status = PrayerTimeStatus.initial,
    this.location,
    this.today,
    this.tomorrow,
    this.now,
    this.message,
  });

  /// Next obligatory prayer, rolling over to tomorrow's Fajr after Isha.
  UpcomingPrayer? get nextPrayer {
    final today = this.today;
    final now = this.now;
    if (today == null || now == null) return null;

    for (final prayer in PrayerNameX.obligatory) {
      final time = today.timeOf(prayer);
      if (time.isAfter(now)) return UpcomingPrayer(prayer, time);
    }
    final tomorrow = this.tomorrow;
    if (tomorrow == null) return null;
    return UpcomingPrayer(PrayerName.fajr, tomorrow.timeOf(PrayerName.fajr));
  }

  /// The obligatory prayer whose time has most recently started today.
  PrayerName? get currentPrayer {
    final today = this.today;
    final now = this.now;
    if (today == null || now == null) return null;

    PrayerName? current;
    for (final prayer in PrayerNameX.obligatory) {
      if (!today.timeOf(prayer).isAfter(now)) current = prayer;
    }
    return current;
  }

  PrayerTimeState copyWith({
    PrayerTimeStatus? status,
    LocationEntity? location,
    PrayerScheduleEntity? today,
    PrayerScheduleEntity? tomorrow,
    DateTime? now,
    String? message,
    bool clearMessage = false,
  }) {
    return PrayerTimeState(
      status: status ?? this.status,
      location: location ?? this.location,
      today: today ?? this.today,
      tomorrow: tomorrow ?? this.tomorrow,
      now: now ?? this.now,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, location, today, tomorrow, now, message];
}
