part of 'ambient_bloc.dart';

sealed class AmbientEvent extends Equatable {
  const AmbientEvent();

  @override
  List<Object?> get props => [];
}

class AmbientSoundsRequested extends AmbientEvent {}

class AmbientSoundToggled extends AmbientEvent {
  final String soundId;

  const AmbientSoundToggled(this.soundId);

  @override
  List<Object?> get props => [soundId];
}

class AmbientVolumeChanged extends AmbientEvent {
  final String soundId;
  final double volume;

  const AmbientVolumeChanged(this.soundId, this.volume);

  @override
  List<Object?> get props => [soundId, volume];
}

class AmbientStopped extends AmbientEvent {}
