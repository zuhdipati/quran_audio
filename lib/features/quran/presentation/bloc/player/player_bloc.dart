import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final ja.AudioPlayer _audioPlayer;

  // stream subscriptions for player updates
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;

  // constructor that sets up event handlers and starts listening to the player
  PlayerBloc({ja.AudioPlayer? audioPlayer})
    : _audioPlayer = audioPlayer ?? ja.AudioPlayer(),
      super(const PlayerState()) {
    on<LoadSurah>(_onLoadSurah);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<NextSurah>(_onNextSurah);
    on<PreviousSurah>(_onPreviousSurah);
    on<SeekAudio>(_onSeekAudio);
    on<UpdatePosition>(_onUpdatePosition);
    on<UpdateDuration>(_onUpdateDuration);
    on<AudioCompleted>(_onAudioCompleted);
    on<StopAudio>(_onStopAudio);

    _listenToAudioPlayer();
  }

  // listens to position, duration, and completion streams from just_audio
  void _listenToAudioPlayer() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      add(UpdatePosition(pos));
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) add(UpdateDuration(dur));
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      if (processingState == ja.ProcessingState.completed) {
        add(AudioCompleted());
      }
    });
  }

  // builds the cdn url for the requested surah audio
  String _buildAudioUrl(String editionIdentifier, int surahNumber) {
    return 'https://cdn.islamic.network/quran/audio-surah/128/$editionIdentifier/$surahNumber.mp3';
  }

  // loads a new surah audio file into the player and auto plays it
  Future<void> _onLoadSurah(LoadSurah event, Emitter<PlayerState> emit) async {
    try {
      emit(
        state.copyWith(
          status: PlayerStatus.loading,
          currentSurah: event.surah,
          editionIdentifier: event.editionIdentifier,
          surahList: event.surahList,
        ),
      );

      final audioUrl = _buildAudioUrl(
        event.editionIdentifier,
        event.surah.number,
      );

      AppLogger.i('Loading audio: $audioUrl');

      await _audioPlayer.setAudioSource(
        ja.AudioSource.uri(Uri.parse(audioUrl)),
      );

      emit(state.copyWith(status: PlayerStatus.paused));

      add(PlayAudio());
    } catch (e, stack) {
      AppLogger.e('Error loading audio', error: e, stackTrace: stack);
      emit(
        state.copyWith(
          status: PlayerStatus.error,
          errorMessage: 'Failed to load audio',
        ),
      );
    }
  }

  // starts playing the current loaded audio
  Future<void> _onPlayAudio(PlayAudio event, Emitter<PlayerState> emit) async {
    emit(state.copyWith(status: PlayerStatus.playing));
    await _audioPlayer.play();
  }

  // pauses the audio playback
  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(status: PlayerStatus.paused));
    await _audioPlayer.pause();
  }

  // resumes the audio from paused state
  Future<void> _onResumeAudio(
    ResumeAudio event,
    Emitter<PlayerState> emit,
  ) async {
    emit(state.copyWith(status: PlayerStatus.playing));
    await _audioPlayer.play();
  }

  // skips to the next surah in the list if available
  Future<void> _onNextSurah(NextSurah event, Emitter<PlayerState> emit) async {
    if (!state.hasNextSurah) return;
    final currentIndex = state.surahList.indexWhere(
      (s) => s.number == state.currentSurah!.number,
    );
    final nextSurah = state.surahList[currentIndex + 1];
    add(
      LoadSurah(
        nextSurah,
        editionIdentifier: state.editionIdentifier,
        surahList: state.surahList,
      ),
    );
  }

  // goes back to the previous surah in the list if available
  Future<void> _onPreviousSurah(
    PreviousSurah event,
    Emitter<PlayerState> emit,
  ) async {
    if (!state.hasPreviousSurah) return;
    final currentIndex = state.surahList.indexWhere(
      (s) => s.number == state.currentSurah!.number,
    );
    final prevSurah = state.surahList[currentIndex - 1];
    add(
      LoadSurah(
        prevSurah,
        editionIdentifier: state.editionIdentifier,
        surahList: state.surahList,
      ),
    );
  }

  // seeks the audio to a specific position
  Future<void> _onSeekAudio(SeekAudio event, Emitter<PlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  // updates the current playback position in the state
  void _onUpdatePosition(UpdatePosition event, Emitter<PlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  // updates the total audio duration in the state
  void _onUpdateDuration(UpdateDuration event, Emitter<PlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  // handles the end of audio playback and auto-plays the next surah
  void _onAudioCompleted(AudioCompleted event, Emitter<PlayerState> emit) {
    emit(
      state.copyWith(status: PlayerStatus.completed, position: state.duration),
    );

    if (!state.hasNextSurah) return;
    final currentIndex = state.surahList.indexWhere(
      (s) => s.number == state.currentSurah!.number,
    );
    final nextSurah = state.surahList[currentIndex + 1];
    add(
      LoadSurah(
        nextSurah,
        editionIdentifier: state.editionIdentifier,
        surahList: state.surahList,
      ),
    );
  }

  // stops playback and resets the player state to initial
  Future<void> _onStopAudio(StopAudio event, Emitter<PlayerState> emit) async {
    await _audioPlayer.stop();
    emit(state.copyWith(status: PlayerStatus.initial));
  }

  // cleans up subscriptions and player resources
  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
