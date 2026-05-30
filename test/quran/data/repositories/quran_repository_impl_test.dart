import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/quran/data/repositories/quran_repository_impl.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late QuranRepositoryImpl repository;
  late MockQuranRemoteDataSource mockRemoteDataSource;
  late MockQuranLocalDataSource mockLocalDataSource;
  late MockInternetConnection mockInternetConnection;

  setUp(() {
    mockRemoteDataSource = MockQuranRemoteDataSource();
    mockLocalDataSource = MockQuranLocalDataSource();
    mockInternetConnection = MockInternetConnection();
    repository = QuranRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      internetConnection: mockInternetConnection,
    );
  });

  group('getAllEdition', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockInternetConnection.hasInternetAccess).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllEdition()).thenAnswer((_) async => tEditionModelList);
      when(() => mockLocalDataSource.cacheEditions(any())).thenAnswer((_) async => Future.value());

      // act
      await repository.getAllEdition();

      // assert
      verify(() => mockInternetConnection.hasInternetAccess).called(1);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockInternetConnection.hasInternetAccess).thenAnswer((_) async => true);
      });

      test('should return remote data when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getAllEdition()).thenAnswer((_) async => tEditionModelList);
        when(() => mockLocalDataSource.cacheEditions(any())).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.getAllEdition();

        // assert
        verify(() => mockRemoteDataSource.getAllEdition());
        result.fold(
          (l) => fail('Expected Right'),
          (r) => expect(r, equals(tEditionEntityList)),
        );
      });

      test('should cache data locally when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getAllEdition()).thenAnswer((_) async => tEditionModelList);
        when(() => mockLocalDataSource.cacheEditions(any())).thenAnswer((_) async => Future.value());

        // act
        await repository.getAllEdition();

        // assert
        verify(() => mockRemoteDataSource.getAllEdition());
        verify(() => mockLocalDataSource.cacheEditions(tEditionModelList));
      });

      test('should return Failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getAllEdition()).thenThrow(GeneralException(message: 'Server Error'));

        // act
        final result = await repository.getAllEdition();

        // assert
        verify(() => mockRemoteDataSource.getAllEdition());
        result.fold(
          (l) => expect(l.message, equals('Server Error')),
          (r) => fail('Expected failure'),
        );
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockInternetConnection.hasInternetAccess).thenAnswer((_) async => false);
      });

      test('should return locally cached data when the cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getAllEdition()).thenAnswer((_) async => tEditionModelList);

        // act
        final result = await repository.getAllEdition();

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getAllEdition());
        result.fold(
          (l) => fail('Expected Right'),
          (r) => expect(r, equals(tEditionEntityList)),
        );
      });
    });
  });

  group('getAllSurah', () {
    final tEdition = 'ar.alafasy';

    group('device is online', () {
      setUp(() {
        when(() => mockInternetConnection.hasInternetAccess).thenAnswer((_) async => true);
      });

      test('should return remote data when the call to remote data source is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getAllSurah(tEdition)).thenAnswer((_) async => tSurahModelList);
        when(() => mockLocalDataSource.cacheDefaultSurahs(any())).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.getAllSurah(tEdition);

        // assert
        verify(() => mockRemoteDataSource.getAllSurah(tEdition));
        result.fold(
          (l) => fail('Expected Right'),
          (r) => expect(r, equals(tSurahEntityList)),
        );
      });

      test('should return Failure when the call to remote data source is unsuccessful', () async {
        // arrange
        when(() => mockRemoteDataSource.getAllSurah(tEdition)).thenThrow(GeneralException(message: 'Server Error'));

        // act
        final result = await repository.getAllSurah(tEdition);

        // assert
        verify(() => mockRemoteDataSource.getAllSurah(tEdition));
        result.fold(
          (l) => expect(l.message, equals('Server Error')),
          (r) => fail('Expected failure'),
        );
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockInternetConnection.hasInternetAccess).thenAnswer((_) async => false);
      });

      test('should return locally cached data when edition is ar.alafasy and cached data is present', () async {
        // arrange
        when(() => mockLocalDataSource.getDefaultSurahs()).thenAnswer((_) async => tSurahModelList);

        // act
        final result = await repository.getAllSurah('ar.alafasy');

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getDefaultSurahs());
        result.fold(
          (l) => fail('Expected Right'),
          (r) => expect(r, equals(tSurahEntityList)),
        );
      });

      test('should return Failure when edition is not ar.alafasy and device is offline', () async {
        // arrange

        // act
        final result = await repository.getAllSurah('en.walk');

        // assert
        result.fold(
          (l) => expect(l.message, equals('No Internet Connection')),
          (r) => fail('Expected failure'),
        );
      });
    });
  });

  group('getSurah', () {
    final tSurahNumber = 1;
    final tEdition = 'ar.alafasy';

    test('should return data when the call to remote data source is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getSurah(tSurahNumber, tEdition)).thenAnswer((_) async => tSurahModel);

      // act
      final result = await repository.getSurah(tSurahNumber, tEdition);

      // assert
      verify(() => mockRemoteDataSource.getSurah(tSurahNumber, tEdition));
      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r, equals(tSurahEntity)),
      );
    });

    test('should return Failure when the call to remote data source is unsuccessful', () async {
      // arrange
      when(() => mockRemoteDataSource.getSurah(tSurahNumber, tEdition)).thenThrow(GeneralException(message: 'Server Error'));

      // act
      final result = await repository.getSurah(tSurahNumber, tEdition);

      // assert
      verify(() => mockRemoteDataSource.getSurah(tSurahNumber, tEdition));
      result.fold(
        (l) => expect(l.message, equals('Server Error')),
        (r) => fail('Expected failure'),
      );
    });
  });
}
