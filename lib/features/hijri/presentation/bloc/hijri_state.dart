part of 'hijri_bloc.dart';

enum HijriStatus { initial, loading, loaded, error }

class HijriState extends Equatable {
  final HijriStatus status;
  final HijriDateEntity? today;
  final DateTime? todayGregorian;
  final HijriMonthEntity? month;
  final List<IslamicEventEntity> upcomingEvents;
  final String? message;

  const HijriState({
    this.status = HijriStatus.initial,
    this.today,
    this.todayGregorian,
    this.month,
    this.upcomingEvents = const [],
    this.message,
  });

  HijriState copyWith({
    HijriStatus? status,
    HijriDateEntity? today,
    DateTime? todayGregorian,
    HijriMonthEntity? month,
    List<IslamicEventEntity>? upcomingEvents,
    String? message,
  }) {
    return HijriState(
      status: status ?? this.status,
      today: today ?? this.today,
      todayGregorian: todayGregorian ?? this.todayGregorian,
      month: month ?? this.month,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    today,
    todayGregorian,
    month,
    upcomingEvents,
    message,
  ];
}
