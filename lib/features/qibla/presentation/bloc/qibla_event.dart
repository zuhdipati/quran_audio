part of 'qibla_bloc.dart';

sealed class QiblaEvent extends Equatable {
  const QiblaEvent();

  @override
  List<Object?> get props => [];
}

class QiblaStarted extends QiblaEvent {
  final LocationEntity location;

  const QiblaStarted(this.location);

  @override
  List<Object?> get props => [location];
}

class QiblaHeadingChanged extends QiblaEvent {
  final double? heading;

  const QiblaHeadingChanged(this.heading);

  @override
  List<Object?> get props => [heading];
}
