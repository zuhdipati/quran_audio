part of 'qibla_bloc.dart';

enum QiblaStatus { initial, waiting, tracking, noSensor }

class QiblaState extends Equatable {
  final QiblaStatus status;
  final LocationEntity? location;
  final double qiblaDirection;
  final double heading;

  const QiblaState({
    this.status = QiblaStatus.initial,
    this.location,
    this.qiblaDirection = 0,
    this.heading = 0,
  });

  /// Degrees the user still has to turn clockwise, in the range -180..180.
  double get turnAngle {
    final diff = (qiblaDirection - heading) % 360;
    return diff > 180 ? diff - 360 : diff;
  }

  bool get isFacingQibla =>
      status == QiblaStatus.tracking && turnAngle.abs() <= 5;

  QiblaState copyWith({
    QiblaStatus? status,
    LocationEntity? location,
    double? qiblaDirection,
    double? heading,
  }) {
    return QiblaState(
      status: status ?? this.status,
      location: location ?? this.location,
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      heading: heading ?? this.heading,
    );
  }

  @override
  List<Object?> get props => [status, location, qiblaDirection, heading];
}
