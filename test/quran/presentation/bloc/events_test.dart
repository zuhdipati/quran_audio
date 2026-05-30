import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';

void main() {
  const tSurah = SurahEntity(
    number: 1,
    name: 'Al-Fatihah',
    englishName: 'Al-Fatihah',
    englishNameTranslation: 'The Opening',
    revelationType: 'Meccan',
    numberOfAyahs: 7,
  );
  
  const tEdition = EditionEntity(
    identifier: 'ar.alafasy',
    language: 'ar',
    name: 'Mishary',
    englishName: 'Mishary Rashid Alafasy',
  );

  group('PlayerEvents', () {
    test('props should be correct', () {
      expect(const LoadSurah(tSurah, editionIdentifier: 'ar.alafasy', surahList: [tSurah]).props, [tSurah, 'ar.alafasy', [tSurah]]);
      expect(PlayAudio().props, []);
      expect(PauseAudio().props, []);
      expect(ResumeAudio().props, []);
      expect(NextSurah().props, []);
      expect(PreviousSurah().props, []);
      expect(const SeekAudio(Duration(seconds: 1)).props, [const Duration(seconds: 1)]);
      expect(const UpdatePosition(Duration(seconds: 1)).props, [const Duration(seconds: 1)]);
      expect(const UpdateDuration(Duration(seconds: 1)).props, [const Duration(seconds: 1)]);
      expect(AudioCompleted().props, []);
      expect(StopAudio().props, []);
    });
  });

  group('SurahListEvents', () {
    test('props should be correct', () {
      expect(const FetchSurahs(tEdition).props, [tEdition]);
      expect(const SearchSurahs('query').props, ['query']);
    });
  });

  group('EditionEvents', () {
    test('props should be correct', () {
      expect(GetEditions().props, []);
      expect(const SearchEditions('query').props, ['query']);
    });
  });
}
