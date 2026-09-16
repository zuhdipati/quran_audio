import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';

enum PrayerName { imsak, fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  String get label => switch (this) {
    PrayerName.imsak => 'Imsak',
    PrayerName.fajr => 'Fajr',
    PrayerName.sunrise => 'Sunrise',
    PrayerName.dhuhr => 'Dzuhr',
    PrayerName.asr => 'Asr',
    PrayerName.maghrib => 'Maghrib',
    PrayerName.isha => 'Isha',
  };

  /// Obligatory prayers, in order, as shown on the home strip.
  static const obligatory = [
    PrayerName.fajr,
    PrayerName.dhuhr,
    PrayerName.asr,
    PrayerName.maghrib,
    PrayerName.isha,
  ];
}

class PrayerScheduleEntity extends Equatable {
  final DateTime date;
  final HijriDateEntity hijri;
  final Map<PrayerName, DateTime> times;

  const PrayerScheduleEntity({
    required this.date,
    required this.hijri,
    required this.times,
  });

  DateTime timeOf(PrayerName prayer) => times[prayer]!;

  @override
  List<Object?> get props => [date, hijri, times];
}
