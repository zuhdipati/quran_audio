import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';

abstract class PrayerTimeRepository {
  /// Returns the cached location, or asks the device when [refresh] is true
  /// or nothing is cached yet.
  Future<Either<Failure, LocationEntity>> getLocation({bool refresh = false});

  Either<Failure, List<PrayerScheduleEntity>> getSchedules(
    LocationEntity location,
    DateTime start,
    int days,
  );

  double getQiblaDirection(LocationEntity location);
}
