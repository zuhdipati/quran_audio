import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String city;
  final bool isFallback;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.isFallback = false,
  });

  /// Jakarta, used until the device location is known.
  static const fallback = LocationModel(
    latitude: -6.2087634,
    longitude: 106.845599,
    city: 'Jakarta',
    isFallback: true,
  );

  factory LocationModel.fromJson(Map<dynamic, dynamic> json) => LocationModel(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    city: json['city'] ?? '',
    isFallback: json['isFallback'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'isFallback': isFallback,
  };

  factory LocationModel.fromEntity(LocationEntity entity) => LocationModel(
    latitude: entity.latitude,
    longitude: entity.longitude,
    city: entity.city,
    isFallback: entity.isFallback,
  );

  LocationEntity toEntity() => LocationEntity(
    latitude: latitude,
    longitude: longitude,
    city: city,
    isFallback: isFallback,
  );
}
