import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';

class HijriDayEntity extends Equatable {
  final HijriDateEntity hijri;
  final DateTime gregorian;

  const HijriDayEntity({required this.hijri, required this.gregorian});

  @override
  List<Object?> get props => [hijri, gregorian];
}

class HijriMonthEntity extends Equatable {
  final int year;
  final int month;
  final String monthName;
  final String monthNameArabic;
  final List<HijriDayEntity> days;
  final List<IslamicEventEntity> events;

  const HijriMonthEntity({
    required this.year,
    required this.month,
    required this.monthName,
    required this.monthNameArabic,
    required this.days,
    required this.events,
  });

  @override
  List<Object?> get props => [
    year,
    month,
    monthName,
    monthNameArabic,
    days,
    events,
  ];
}
