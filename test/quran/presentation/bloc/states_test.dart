import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';

void main() {
  const tSurah1 = SurahEntity(
    number: 1,
    name: 'Al-Fatihah',
    englishName: 'Al-Fatihah',
    englishNameTranslation: 'The Opening',
    revelationType: 'Meccan',
    numberOfAyahs: 7,
  );
  
  const tSurah2 = SurahEntity(
    number: 2,
    name: 'Al-Baqarah',
    englishName: 'Al-Baqarah',
    englishNameTranslation: 'The Cow',
    revelationType: 'Medinan',
    numberOfAyahs: 286,
  );

  group('PlayerState', () {
    test('props should be correct', () {
      const state = PlayerState();
      expect(state.props, [PlayerStatus.initial, null, '', [], Duration.zero, Duration.zero, '']);
    });

    test('copyWith should return updated state', () {
      const state = PlayerState();
      final updated = state.copyWith(
        status: PlayerStatus.playing,
        currentSurah: tSurah1,
        editionIdentifier: 'ar.alafasy',
        surahList: [tSurah1, tSurah2],
        duration: const Duration(seconds: 10),
        position: const Duration(seconds: 5),
        errorMessage: 'error',
      );
      expect(updated.status, PlayerStatus.playing);
      expect(updated.currentSurah, tSurah1);
      expect(updated.editionIdentifier, 'ar.alafasy');
      expect(updated.surahList, [tSurah1, tSurah2]);
      expect(updated.duration, const Duration(seconds: 10));
      expect(updated.position, const Duration(seconds: 5));
      expect(updated.errorMessage, 'error');
    });

    test('hasPreviousSurah and hasNextSurah should return correct boolean', () {
      const state1 = PlayerState(
        currentSurah: tSurah1,
        surahList: [tSurah1, tSurah2],
      );
      expect(state1.hasPreviousSurah, false);
      expect(state1.hasNextSurah, true);

      const state2 = PlayerState(
        currentSurah: tSurah2,
        surahList: [tSurah1, tSurah2],
      );
      expect(state2.hasPreviousSurah, true);
      expect(state2.hasNextSurah, false);
      
      const state3 = PlayerState(
        currentSurah: tSurah1,
        surahList: [],
      );
      expect(state3.hasPreviousSurah, false);
      expect(state3.hasNextSurah, false);
    });
  });
}
