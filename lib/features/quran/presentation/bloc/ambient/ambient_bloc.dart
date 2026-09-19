import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_ambient_sounds.dart';
import 'package:quran_audio/core/error/error_keys.dart';

part 'ambient_event.dart';
part 'ambient_state.dart';

/// Mixes looping nature sounds underneath the recitation. Every active sound
/// has its own player so each can have an independent volume. A sound's
/// recording is downloaded the first time it is switched on.
class AmbientBloc extends Bloc<AmbientEvent, AmbientState> {
  final GetAmbientSounds getAmbientSounds;
  final GetAmbientSoundFile getAmbientSoundFile;
  final ja.AudioPlayer Function() _playerFactory;

  final Map<String, ja.AudioPlayer> _players = {};

  AmbientBloc({
    required this.getAmbientSounds,
    required this.getAmbientSoundFile,
    ja.AudioPlayer Function()? playerFactory,
  }) : _playerFactory = playerFactory ?? ja.AudioPlayer.new,
       super(const AmbientState()) {
    on<AmbientSoundsRequested>(_onRequested);
    on<AmbientSoundToggled>(_onToggled);
    on<AmbientVolumeChanged>(_onVolumeChanged);
    on<AmbientStopped>(_onStopped);
  }

  Future<void> _onRequested(
    AmbientSoundsRequested event,
    Emitter<AmbientState> emit,
  ) async {
    if (state.status == AmbientStatus.loaded) return;
    final result = await getAmbientSounds();
    result.fold(
      (failure) => emit(
        state.copyWith(status: AmbientStatus.error, message: failure.message),
      ),
      (sounds) =>
          emit(state.copyWith(status: AmbientStatus.loaded, sounds: sounds)),
    );
  }

  Future<void> _onToggled(
    AmbientSoundToggled event,
    Emitter<AmbientState> emit,
  ) async {
    final id = event.soundId;
    if (state.activeIds.contains(id)) {
      emit(state.copyWith(activeIds: {...state.activeIds}..remove(id)));
      await _release(id);
      return;
    }

    final sound = state.soundById(id);
    if (sound == null) return;

    emit(
      state.copyWith(
        activeIds: {...state.activeIds, id},
        loadingIds: {...state.loadingIds, id},
      ),
    );

    final file = await getAmbientSoundFile(sound);
    final path = file.fold((failure) => null, (path) => path);
    if (path == null) {
      emit(
        state.copyWith(
          activeIds: {...state.activeIds}..remove(id),
          loadingIds: {...state.loadingIds}..remove(id),
          message: file.fold((failure) => failure.message, (_) => null),
        ),
      );
      return;
    }
    emit(state.copyWith(loadingIds: {...state.loadingIds}..remove(id)));

    // switched off while downloading, or already started by a second tap
    // that waited on the same download
    if (!state.isActive(id) || _players.containsKey(id)) return;

    try {
      final player = _playerFactory();
      _players[id] = player;
      await player.setFilePath(path);
      await player.setLoopMode(ja.LoopMode.one);
      await player.setVolume(state.volumeOf(id));
      // play() completes only when playback stops, so don't await it
      player.play();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to play ${sound.file}',
        error: e,
        stackTrace: stackTrace,
      );
      await _release(id);
      emit(
        state.copyWith(
          activeIds: {...state.activeIds}..remove(id),
          message: ErrorKeys.playSound,
        ),
      );
    }
  }

  Future<void> _onVolumeChanged(
    AmbientVolumeChanged event,
    Emitter<AmbientState> emit,
  ) async {
    final volume = event.volume.clamp(0.0, 1.0);
    emit(state.copyWith(volumes: {...state.volumes, event.soundId: volume}));
    await _players[event.soundId]?.setVolume(volume);
  }

  Future<void> _onStopped(
    AmbientStopped event,
    Emitter<AmbientState> emit,
  ) async {
    final ids = _players.keys.toList();
    emit(state.copyWith(activeIds: const {}));
    for (final id in ids) {
      await _release(id);
    }
  }

  Future<void> _release(String id) async {
    final player = _players.remove(id);
    if (player == null) return;
    try {
      await player.stop();
      await player.dispose();
    } catch (e) {
      AppLogger.w('Failed to release ambient player', error: e);
    }
  }

  @override
  Future<void> close() async {
    for (final id in _players.keys.toList()) {
      await _release(id);
    }
    return super.close();
  }
}
