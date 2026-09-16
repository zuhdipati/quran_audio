import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_device_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_local_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/prayer_time_calculator_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/models/location_model.dart';
import 'package:quran_audio/features/prayer_time/data/repositories/prayer_time_repository_impl.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';

class MockDevice extends Mock implements LocationDeviceDataSource {}

class MockLocal extends Mock implements LocationLocalDataSource {}

void main() {
  late MockDevice device;
  late MockLocal local;
  late PrayerTimeRepositoryImpl repository;

  const jakarta = LocationModel(
    latitude: -6.2087634,
    longitude: 106.845599,
    city: 'Jakarta',
  );

  setUpAll(() => registerFallbackValue(jakarta));

  setUp(() {
    device = MockDevice();
    local = MockLocal();
    when(() => local.cacheLocation(any())).thenAnswer((_) async {});
    repository = PrayerTimeRepositoryImpl(
      deviceDataSource: device,
      localDataSource: local,
      calculatorDataSource: PrayerTimeCalculatorDataSourceImpl(),
      hijriDataSource: HijriLocalDataSourceImpl(loader: AssetJsonLoader()),
    );
  });

  group('getLocation', () {
    test('returns the cached location without asking the device', () async {
      when(() => local.getCachedLocation()).thenAnswer((_) async => jakarta);

      final result = await repository.getLocation();

      expect(result.getOrElse(() => throw 'x').city, equals('Jakarta'));
      verifyZeroInteractions(device);
    });

    test('asks the device and caches when nothing is cached', () async {
      when(() => local.getCachedLocation()).thenAnswer((_) async => null);
      when(() => device.getCurrentLocation()).thenAnswer((_) async => jakarta);

      await repository.getLocation();

      verify(() => local.cacheLocation(jakarta)).called(1);
    });

    test('falls back to Jakarta when the device fails on first load', () async {
      when(() => local.getCachedLocation()).thenAnswer((_) async => null);
      when(
        () => device.getCurrentLocation(),
      ).thenThrow(GeneralException(message: 'Location permission denied'));

      final result = await repository.getLocation();

      final location = result.getOrElse(() => throw 'x');
      expect(location.isFallback, isTrue);
    });

    test('reports the failure when an explicit refresh fails', () async {
      when(() => local.getCachedLocation()).thenAnswer((_) async => jakarta);
      when(
        () => device.getCurrentLocation(),
      ).thenThrow(GeneralException(message: 'Location permission denied'));

      final result = await repository.getLocation(refresh: true);

      result.fold(
        (failure) => expect(failure.message, 'Location permission denied'),
        (_) => fail('expected failure'),
      );
    });
  });

  group('getSchedules', () {
    test('matches Kemenag RI times for Jakarta within two minutes', () {
      final result = repository.getSchedules(
        jakarta.toEntity(),
        DateTime(2026, 9, 16),
        1,
      );
      final schedule = result.getOrElse(() => throw 'x').single;

      // Aladhan method 20 (Kemenag) for 16 Sep 2026, UTC+7
      const expected = {
        PrayerName.fajr: '04:28',
        PrayerName.sunrise: '05:46',
        PrayerName.dhuhr: '11:48',
        PrayerName.asr: '15:00',
        PrayerName.maghrib: '17:50',
        PrayerName.isha: '18:59',
      };
      expected.forEach((prayer, hhmm) {
        final wib = schedule
            .timeOf(prayer)
            .toUtc()
            .add(const Duration(hours: 7));
        final parts = hhmm.split(':').map(int.parse).toList();
        final target = DateTime.utc(
          wib.year,
          wib.month,
          wib.day,
          parts[0],
          parts[1],
        );
        expect(
          wib.difference(target).inMinutes.abs(),
          lessThanOrEqualTo(2),
          reason: '$prayer was $wib',
        );
      });
      expect(schedule.hijri.formatted, equals('5 Rabiul Akhir 1448 H'));
    });

    test('generates one schedule per requested day', () {
      final result = repository.getSchedules(
        jakarta.toEntity(),
        DateTime(2026, 2, 1),
        28,
      );
      final schedules = result.getOrElse(() => throw 'x');

      expect(schedules.length, equals(28));
      expect(schedules.last.date, equals(DateTime(2026, 2, 28)));
    });
  });

  test('qibla from Jakarta points north-west towards Makkah', () {
    final direction = repository.getQiblaDirection(jakarta.toEntity());
    expect(direction, closeTo(295.15, 0.1));
  });
}
