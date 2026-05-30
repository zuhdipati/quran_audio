import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/data/models/ayah_model.dart';

void main() {
  const tAyahModel = AyahModel(
    number: 1,
    audio: 'http://example.com/audio.mp3',
    text: 'Bismillah',
    numberInSurah: 1,
    juz: 1,
    manzil: 1,
    page: 1,
    ruku: 1,
    hizbQuarter: 1,
    sajda: false,
  );

  group('AyahModel', () {
    test('should return a valid model from json', () {
      final jsonMap = {
        "number": 1,
        "audio": "http://example.com/audio.mp3",
        "text": "Bismillah",
        "numberInSurah": 1,
        "juz": 1,
        "manzil": 1,
        "page": 1,
        "ruku": 1,
        "hizbQuarter": 1,
        "sajda": false
      };

      final result = AyahModel.fromJson(jsonMap);

      expect(result.number, equals(1));
      expect(result.audio, equals('http://example.com/audio.mp3'));
      expect(result.text, equals('Bismillah'));
      expect(result.sajda, equals(false));
    });

    test('should return a valid model from json with null sajda', () {
      final jsonMap = {
        "number": 1,
        "audio": "http://example.com/audio.mp3",
        "text": "Bismillah",
        "numberInSurah": 1,
        "juz": 1,
        "manzil": 1,
        "page": 1,
        "ruku": 1,
        "hizbQuarter": 1,
        "sajda": null
      };

      final result = AyahModel.fromJson(jsonMap);

      expect(result.sajda, equals(false));
    });

    test('should return a json map containing the proper data', () {
      final result = tAyahModel.toJson();

      final expectedMap = {
        "number": 1,
        "audio": "http://example.com/audio.mp3",
        "text": "Bismillah",
        "numberInSurah": 1,
        "juz": 1,
        "manzil": 1,
        "page": 1,
        "ruku": 1,
        "hizbQuarter": 1,
        "sajda": false
      };

      expect(result, equals(expectedMap));
    });
  });
}
