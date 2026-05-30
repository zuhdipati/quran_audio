import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

final tEditionModel = EditionModel(
  identifier: 'ar.alafasy',
  language: 'ar',
  name: 'Alafasy',
  englishName: 'Alafasy',
  format: 'audio',
  type: 'versebyverse',
  direction: null,
);

final tEditionEntity = EditionEntity(
  identifier: 'ar.alafasy',
  language: 'ar',
  name: 'Alafasy',
  englishName: 'Alafasy',
);

final tEditionModelList = [tEditionModel];
final tEditionEntityList = [tEditionEntity];

final tSurahModel = SurahModel(
  number: 1,
  name: 'سُورَةُ ٱلْفَاتِحَةِ',
  englishName: 'Al-Faatiha',
  englishNameTranslation: 'The Opening',
  revelationType: 'Meccan',
  numberOfAyahs: 7,
  ayahs: const [],
  edition: tEditionModel,
);

final tSurahEntity = SurahEntity(
  number: 1,
  name: 'سُورَةُ ٱلْفَاتِحَةِ',
  englishName: 'Al-Faatiha',
  englishNameTranslation: 'The Opening',
  revelationType: 'Meccan',
  numberOfAyahs: 7,
);

final tSurahModelList = [tSurahModel];
final tSurahEntityList = [tSurahEntity];
