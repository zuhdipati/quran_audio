import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

enum PlayerStatus { initial, loading, playing, paused, completed, error }

class PlayerState extends Equatable {
  final PlayerStatus status;
  final SurahEntity? currentSurah;
  final String editionIdentifier;
  final List<SurahEntity> surahList;
  final Duration position;
  final Duration duration;
  final String errorMessage;
  final double volume;

  const PlayerState({
    this.status = PlayerStatus.initial,
    this.currentSurah,
    this.editionIdentifier = '',
    this.surahList = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage = '',
    this.volume = 1.0,
  });

  bool get hasNextSurah {
    if (currentSurah == null || surahList.isEmpty) return false;
    final currentIndex = surahList.indexWhere(
      (s) => s.number == currentSurah!.number,
    );
    return currentIndex >= 0 && currentIndex < surahList.length - 1;
  }

  bool get hasPreviousSurah {
    if (currentSurah == null || surahList.isEmpty) return false;
    final currentIndex = surahList.indexWhere(
      (s) => s.number == currentSurah!.number,
    );
    return currentIndex > 0;
  }

  PlayerState copyWith({
    PlayerStatus? status,
    SurahEntity? currentSurah,
    String? editionIdentifier,
    List<SurahEntity>? surahList,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    double? volume,
  }) {
    return PlayerState(
      status: status ?? this.status,
      currentSurah: currentSurah ?? this.currentSurah,
      editionIdentifier: editionIdentifier ?? this.editionIdentifier,
      surahList: surahList ?? this.surahList,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentSurah,
    editionIdentifier,
    surahList,
    position,
    duration,
    errorMessage,
    volume,
  ];
}
