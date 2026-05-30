import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  group('EditionModel', () {
    test('should be able to convert to EditionEntity', () async {
      expect(tEditionModel.toEntity(), equals(tEditionEntity));
    });

    test('should return a valid model from json', () async {
      final Map<String, dynamic> jsonMap = {
        "identifier": "ar.alafasy",
        "language": "ar",
        "name": "Alafasy",
        "englishName": "Alafasy",
        "format": "audio",
        "type": "versebyverse",
        "direction": null
      };

      final result = EditionModel.fromJson(jsonMap);

      expect(result.identifier, equals("ar.alafasy"));
      expect(result.language, equals("ar"));
      expect(result.name, equals("Alafasy"));
      expect(result.format, equals("audio"));
    });

    test('should return a valid model from identifier', () async {
      final identifier = "ar.alafasy";
      final result = EditionModel.fromIdentifier(identifier);

      expect(result.identifier, equals("ar.alafasy"));
      expect(result.language, equals("ar"));
      expect(result.englishName, equals("Alafasy"));
    });

    test('should return a json map containing the proper data', () async {
      final result = tEditionModel.toJson();
      final expectedMap = {
        "identifier": "ar.alafasy",
        "language": "ar",
        "name": "Alafasy",
        "englishName": "Alafasy",
        "format": "audio",
        "type": "versebyverse",
        "direction": null
      };

      expect(result, equals(expectedMap));
    });
  });
}
