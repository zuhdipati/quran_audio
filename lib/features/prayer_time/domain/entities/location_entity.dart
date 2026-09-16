import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final String city;

  /// True when the device location is unavailable and a fallback is used.
  final bool isFallback;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.isFallback = false,
  });

  @override
  List<Object?> get props => [latitude, longitude, city, isFallback];
}
