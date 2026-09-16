import 'package:hive/hive.dart';
import 'package:quran_audio/features/prayer_time/data/models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<LocationModel?> getCachedLocation();
  Future<void> cacheLocation(LocationModel location);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Box box;

  LocationLocalDataSourceImpl({required this.box});

  static const _key = 'last_location';

  @override
  Future<LocationModel?> getCachedLocation() async {
    final data = box.get(_key);
    if (data is! Map) return null;
    return LocationModel.fromJson(data);
  }

  @override
  Future<void> cacheLocation(LocationModel location) async {
    await box.put(_key, location.toJson());
  }
}
