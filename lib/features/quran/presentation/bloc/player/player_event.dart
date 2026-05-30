import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object> get props => [];
}

class LoadSurah extends PlayerEvent {
  final SurahEntity surah;
  final String editionIdentifier;
  final List<SurahEntity> surahList;

  const LoadSurah(
    this.surah, {
    required this.editionIdentifier,
    required this.surahList,
  });

  @override
  List<Object> get props => [surah, editionIdentifier, surahList];
}

class NextSurah extends PlayerEvent {}

class PreviousSurah extends PlayerEvent {}

class PlayAudio extends PlayerEvent {}

class PauseAudio extends PlayerEvent {}

class ResumeAudio extends PlayerEvent {}

class SeekAudio extends PlayerEvent {
  final Duration position;

  const SeekAudio(this.position);

  @override
  List<Object> get props => [position];
}

class UpdatePosition extends PlayerEvent {
  final Duration position;
  const UpdatePosition(this.position);
  @override
  List<Object> get props => [position];
}

class UpdateDuration extends PlayerEvent {
  final Duration duration;
  const UpdateDuration(this.duration);
  @override
  List<Object> get props => [duration];
}

class AudioCompleted extends PlayerEvent {}

class StopAudio extends PlayerEvent {}
