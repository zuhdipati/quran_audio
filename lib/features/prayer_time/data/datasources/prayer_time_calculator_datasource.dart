import 'package:adhan/adhan.dart';
import 'package:quran_audio/features/prayer_time/data/models/location_model.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';

abstract class PrayerTimeCalculatorDataSource {
  Map<PrayerName, DateTime> calculate(LocationModel location, DateTime date);
  double qiblaDirection(LocationModel location);
}

/// Offline astronomical calculation.
///
/// Uses the Kemenag RI angles (Fajr 20°, Isha 18°, Shafi'i Asr), which
/// matches Aladhan's method 20 within a minute.
class PrayerTimeCalculatorDataSourceImpl
    implements PrayerTimeCalculatorDataSource {
  static const imsakOffset = Duration(minutes: 10);

  CalculationParameters get _parameters =>
      CalculationMethod.singapore.getParameters()..madhab = Madhab.shafi;

  @override
  Map<PrayerName, DateTime> calculate(LocationModel location, DateTime date) {
    final times = PrayerTimes(
      Coordinates(location.latitude, location.longitude),
      DateComponents(date.year, date.month, date.day),
      _parameters,
    );

    final fajr = times.fajr.toLocal();
    return {
      PrayerName.imsak: fajr.subtract(imsakOffset),
      PrayerName.fajr: fajr,
      PrayerName.sunrise: times.sunrise.toLocal(),
      PrayerName.dhuhr: times.dhuhr.toLocal(),
      PrayerName.asr: times.asr.toLocal(),
      PrayerName.maghrib: times.maghrib.toLocal(),
      PrayerName.isha: times.isha.toLocal(),
    };
  }

  @override
  double qiblaDirection(LocationModel location) {
    return Qibla(Coordinates(location.latitude, location.longitude)).direction;
  }
}
