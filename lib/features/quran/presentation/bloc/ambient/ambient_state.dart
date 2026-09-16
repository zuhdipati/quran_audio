part of 'ambient_bloc.dart';

enum AmbientStatus { initial, loaded, error }

class AmbientState extends Equatable {
  static const defaultVolume = 0.4;

  final AmbientStatus status;
  final List<AmbientSoundEntity> sounds;
  final Set<String> activeIds;

  /// Remembered per sound, also while the sound is switched off.
  final Map<String, double> volumes;
  final String? message;

  const AmbientState({
    this.status = AmbientStatus.initial,
    this.sounds = const [],
    this.activeIds = const {},
    this.volumes = const {},
    this.message,
  });

  double volumeOf(String id) => volumes[id] ?? defaultVolume;

  bool isActive(String id) => activeIds.contains(id);

  AmbientSoundEntity? soundById(String id) {
    for (final sound in sounds) {
      if (sound.id == id) return sound;
    }
    return null;
  }

  List<AmbientSoundEntity> get activeSounds =>
      sounds.where((sound) => activeIds.contains(sound.id)).toList();

  AmbientState copyWith({
    AmbientStatus? status,
    List<AmbientSoundEntity>? sounds,
    Set<String>? activeIds,
    Map<String, double>? volumes,
    String? message,
  }) {
    return AmbientState(
      status: status ?? this.status,
      sounds: sounds ?? this.sounds,
      activeIds: activeIds ?? this.activeIds,
      volumes: volumes ?? this.volumes,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sounds, activeIds, volumes, message];
}
