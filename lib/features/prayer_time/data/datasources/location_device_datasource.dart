import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/prayer_time/data/models/location_model.dart';

abstract class LocationDeviceDataSource {
  Future<LocationModel> getCurrentLocation();
}

class LocationDeviceDataSourceImpl implements LocationDeviceDataSource {
  @override
  Future<LocationModel> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw GeneralException(message: 'Location service is turned off');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw GeneralException(message: 'Location permission denied');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        city: await _resolveCity(position.latitude, position.longitude),
      );
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get location', error: e, stackTrace: stackTrace);
      throw GeneralException(message: 'Unable to determine your location');
    }
  }

  // reverse geocoding needs network, so a failure only loses the label
  Future<String> _resolveCity(double latitude, double longitude) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isEmpty) return _coordinateLabel(latitude, longitude);
      final place = placemarks.first;
      final candidates = [
        place.subAdministrativeArea,
        place.locality,
        place.administrativeArea,
      ];
      return candidates.firstWhere(
        (name) => name != null && name.trim().isNotEmpty,
        orElse: () => _coordinateLabel(latitude, longitude),
      )!;
    } catch (e) {
      AppLogger.w('Reverse geocoding failed', error: e);
      return _coordinateLabel(latitude, longitude);
    }
  }

  String _coordinateLabel(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
}
