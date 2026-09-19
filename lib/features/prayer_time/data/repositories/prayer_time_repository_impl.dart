import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_device_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_local_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/prayer_time_calculator_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/models/location_model.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/repositories/prayer_time_repository.dart';
import 'package:quran_audio/core/error/error_keys.dart';

class PrayerTimeRepositoryImpl implements PrayerTimeRepository {
  final LocationDeviceDataSource deviceDataSource;
  final LocationLocalDataSource localDataSource;
  final PrayerTimeCalculatorDataSource calculatorDataSource;
  final HijriLocalDataSource hijriDataSource;

  PrayerTimeRepositoryImpl({
    required this.deviceDataSource,
    required this.localDataSource,
    required this.calculatorDataSource,
    required this.hijriDataSource,
  });

  @override
  Future<Either<Failure, LocationEntity>> getLocation({
    bool refresh = false,
  }) async {
    final cached = await localDataSource.getCachedLocation();
    if (!refresh && cached != null && !cached.isFallback) {
      return Right(cached.toEntity());
    }

    try {
      final location = await deviceDataSource.getCurrentLocation();
      await localDataSource.cacheLocation(location);
      return Right(location.toEntity());
    } on GeneralException catch (e) {
      if (refresh) return Left(Failure(e.message));
      return Right((cached ?? LocationModel.fallback).toEntity());
    } catch (e) {
      if (refresh) return Left(Failure(ErrorKeys.locationUnavailable));
      return Right((cached ?? LocationModel.fallback).toEntity());
    }
  }

  @override
  Either<Failure, List<PrayerScheduleEntity>> getSchedules(
    LocationEntity location,
    DateTime start,
    int days,
  ) {
    try {
      final model = LocationModel.fromEntity(location);
      final schedules = List.generate(days, (index) {
        final date = DateTime(start.year, start.month, start.day + index);
        return PrayerScheduleEntity(
          date: date,
          hijri: hijriDataSource.toHijri(date),
          times: calculatorDataSource.calculate(model, date),
        );
      });
      return Right(schedules);
    } catch (e) {
      return Left(Failure(ErrorKeys.calculatePrayerTimes));
    }
  }

  @override
  double getQiblaDirection(LocationEntity location) {
    return calculatorDataSource.qiblaDirection(
      LocationModel.fromEntity(location),
    );
  }
}
