import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/data/datasources/local_datasource.dart';

import '../../dummy_data/dummy_objects.dart';

class MockBox extends Mock implements Box {}

void main() {
  late QuranLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = QuranLocalDataSourceImpl(box: mockBox);
  });

  group('getAllEdition', () {
    test('should return list of EditionModel from cache when there is one in the cache', () async {
      // arrange
      when(() => mockBox.get('all_edition')).thenReturn(tEditionModelList);

      // act
      final result = await dataSource.getAllEdition();

      // assert
      expect(result, equals(tEditionModelList));
    });

    test('should return empty list when cache is empty', () async {
      // arrange
      when(() => mockBox.get('all_edition')).thenReturn(null);

      // act
      final result = await dataSource.getAllEdition();

      // assert
      expect(result, equals([]));
    });
  });

  group('cacheEditions', () {
    test('should call Box to cache the data', () async {
      // arrange
      when(() => mockBox.put('all_edition', tEditionModelList)).thenAnswer((_) async => Future.value());

      // act
      await dataSource.cacheEditions(tEditionModelList);

      // assert
      verify(() => mockBox.put('all_edition', tEditionModelList)).called(1);
    });
  });

  group('getDefaultSurahs', () {
    test('should return list of SurahModel from cache when there is one in the cache', () async {
      // arrange
      final expectedJsonString = jsonEncode(tSurahModelList.map((e) => e.toJson()).toList());
      when(() => mockBox.get('default_surahs')).thenReturn(expectedJsonString);

      // act
      final result = await dataSource.getDefaultSurahs();

      // assert
      expect(result.map((e) => e.toEntity()).toList(), equals(tSurahEntityList));
    });

    test('should return empty list when cache is empty', () async {
      // arrange
      when(() => mockBox.get('default_surahs')).thenReturn(null);

      // act
      final result = await dataSource.getDefaultSurahs();

      // assert
      expect(result, equals([]));
    });
  });

  group('cacheDefaultSurahs', () {
    test('should call Box to cache the surahs after removing ayahs', () async {
      // arrange
      final expectedList = tSurahModelList.map((surah) {
        final json = surah.toJson();
        json['ayahs'] = [];
        return json;
      }).toList();
      final expectedJsonString = jsonEncode(expectedList);

      when(() => mockBox.put('default_surahs', expectedJsonString)).thenAnswer((_) async => Future.value());

      // act
      await dataSource.cacheDefaultSurahs(tSurahModelList);

      // assert
      verify(() => mockBox.put('default_surahs', expectedJsonString)).called(1);
    });
  });
}
