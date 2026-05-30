import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/features/quran/data/datasources/remote_datasource.dart';

import '../../helpers/test_helper.dart';

void main() {
  late QuranRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = QuranRemoteDataSourceImpl(dio: mockDio);
  });

  group('getAllEdition', () {
    final tResponseData = [
      {
        "type": "directory",
        "name": "/mnt/cdn/islamic-network-cdn/quran/audio-surah",
        "contents": [
          {
            "type": "directory",
            "name": "128",
            "contents": [
              {
                "type": "directory",
                "name": "ar.alafasy",
              }
            ]
          }
        ]
      }
    ];

    test('should return list of EditionModel when response code is 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: tResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: urlGetCdnInfo),
              ));

      final result = await dataSource.getAllEdition();
      expect(result.length, equals(1));
      expect(result.first.identifier, equals('ar.alafasy'));
    });

    test('should throw GeneralException when no audio editions found', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: [
                  {
                    "type": "directory",
                    "name": "/mnt/cdn/islamic-network-cdn/quran/audio-surah",
                    "contents": []
                  }
                ],
                statusCode: 200,
                requestOptions: RequestOptions(path: urlGetCdnInfo),
              ));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException when response code is not 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: 'error',
                statusCode: 500,
                requestOptions: RequestOptions(path: urlGetCdnInfo),
              ));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on connectionTimeout', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetCdnInfo),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on badResponse', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetCdnInfo),
        response: Response(statusCode: 404, requestOptions: RequestOptions(path: urlGetCdnInfo)),
        type: DioExceptionType.badResponse,
      ));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on other DioException', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetCdnInfo),
        type: DioExceptionType.cancel,
      ));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on non-DioException error', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(Exception('Unknown error'));

      expect(() => dataSource.getAllEdition(), throwsA(isA<Exception>()));
    });
  });

  group('getAllSurah', () {
    final tEdition = 'ar.alafasy';
    final tResponseData = {
      "data": {
        "surahs": [
          {
            "number": 1,
            "name": "سُورَةُ ٱلْفَاتِحَةِ",
            "englishName": "Al-Faatiha",
            "englishNameTranslation": "The Opening",
            "revelationType": "Meccan",
            "numberOfAyahs": 7
          }
        ]
      }
    };

    test('should return list of SurahModel when response is 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: tResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: urlGetAllSurah(tEdition)),
              ));

      final result = await dataSource.getAllSurah(tEdition);
      expect(result.length, equals(1));
    });

    test('should throw GeneralException when response code is not 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: 'error',
                statusCode: 500,
                requestOptions: RequestOptions(path: urlGetAllSurah(tEdition)),
              ));

      expect(() => dataSource.getAllSurah(tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on connectionTimeout', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetAllSurah(tEdition)),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(() => dataSource.getAllSurah(tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on badResponse', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetAllSurah(tEdition)),
        response: Response(statusCode: 404, requestOptions: RequestOptions(path: urlGetAllSurah(tEdition))),
        type: DioExceptionType.badResponse,
      ));

      expect(() => dataSource.getAllSurah(tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on other DioException', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetAllSurah(tEdition)),
        type: DioExceptionType.cancel,
      ));

      expect(() => dataSource.getAllSurah(tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on non-DioException error', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(Exception('Unknown error'));

      expect(() => dataSource.getAllSurah(tEdition), throwsA(isA<Exception>()));
    });
  });

  group('getSurah', () {
    final tEdition = 'ar.alafasy';
    final tSurahNumber = 1;
    final tResponseData = {
      "data": {
        "number": 1,
        "name": "سُورَةُ ٱلْفَاتِحَةِ",
        "englishName": "Al-Faatiha",
        "englishNameTranslation": "The Opening",
        "revelationType": "Meccan",
        "numberOfAyahs": 7
      }
    };

    test('should return SurahModel when response is 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: tResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition)),
              ));

      final result = await dataSource.getSurah(tSurahNumber, tEdition);
      expect(result.number, equals(1));
    });

    test('should throw GeneralException when response code is not 200', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenAnswer((_) async => Response(
                data: 'error',
                statusCode: 500,
                requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition)),
              ));

      expect(() => dataSource.getSurah(tSurahNumber, tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on connectionTimeout', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition)),
        type: DioExceptionType.connectionTimeout,
      ));

      expect(() => dataSource.getSurah(tSurahNumber, tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on badResponse', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition)),
        response: Response(statusCode: 404, requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition))),
        type: DioExceptionType.badResponse,
      ));

      expect(() => dataSource.getSurah(tSurahNumber, tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on other DioException', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: urlGetSurah(tSurahNumber.toString(), tEdition)),
        type: DioExceptionType.cancel,
      ));

      expect(() => dataSource.getSurah(tSurahNumber, tEdition), throwsA(isA<Exception>()));
    });

    test('should throw GeneralException on non-DioException error', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(Exception('Unknown error'));

      expect(() => dataSource.getSurah(tSurahNumber, tEdition), throwsA(isA<Exception>()));
    });
  });
}
