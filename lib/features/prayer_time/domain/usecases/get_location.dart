import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/repositories/prayer_time_repository.dart';

class GetLocation {
  final PrayerTimeRepository repository;

  GetLocation(this.repository);

  Future<Either<Failure, LocationEntity>> call({bool refresh = false}) {
    return repository.getLocation(refresh: refresh);
  }
}
