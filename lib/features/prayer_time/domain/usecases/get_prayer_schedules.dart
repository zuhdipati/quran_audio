import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/repositories/prayer_time_repository.dart';

class GetPrayerSchedules {
  final PrayerTimeRepository repository;

  GetPrayerSchedules(this.repository);

  Either<Failure, List<PrayerScheduleEntity>> call(
    LocationEntity location,
    DateTime start, {
    int days = 1,
  }) {
    return repository.getSchedules(location, start, days);
  }
}
