import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  group('SurahModel', () {
    test('should be able to convert to SurahEntity', () async {
      expect(tSurahModel.toEntity(), equals(tSurahEntity));
    });

    test('should return a valid model from json', () async {
      final Map<String, dynamic> jsonMap = {
        "number": 1,
        "name": "سُورَةُ ٱلْفَاتِحَةِ",
        "englishName": "Al-Faatiha",
        "englishNameTranslation": "The Opening",
        "revelationType": "Meccan",
        "numberOfAyahs": 7
      };

      final result = SurahModel.fromJson(jsonMap);

      expect(result.number, equals(1));
      expect(result.name, equals("سُورَةُ ٱلْفَاتِحَةِ"));
      expect(result.englishName, equals("Al-Faatiha"));
      expect(result.numberOfAyahs, equals(7));
    });

    test('should return a json map containing the proper data', () async {
      final result = tSurahModel.toJson();
      final expectedMap = {
        "number": 1,
        "name": "سُورَةُ ٱلْفَاتِحَةِ",
        "englishName": "Al-Faatiha",
        "englishNameTranslation": "The Opening",
        "revelationType": "Meccan",
        "numberOfAyahs": 7,
        "ayahs": [],
        "edition": tEditionModel.toJson()
      };

      expect(result, equals(expectedMap));
    });
  });
}
