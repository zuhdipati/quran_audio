import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/repositories/prayer_time_repository.dart';

class GetQiblaDirection {
  final PrayerTimeRepository repository;

  GetQiblaDirection(this.repository);

  double call(LocationEntity location) =>
      repository.getQiblaDirection(location);
}
