import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/prayer_schedule_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_location.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_prayer_schedules.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';

class MockGetLocation extends Mock implements GetLocation {}

class MockGetPrayerSchedules extends Mock implements GetPrayerSchedules {}

const tLocation = LocationEntity(
  latitude: -6.2,
  longitude: 106.8,
  city: 'Jakarta',
);
const tHijri = HijriDateEntity(
  day: 5,
  month: 4,
  year: 1448,
  monthName: 'Rabiul Akhir',
  monthNameArabic: 'رَبِيع الآخِر',
);

PrayerScheduleEntity schedule(DateTime date) {
  DateTime at(int h, int m) => DateTime(date.year, date.month, date.day, h, m);
  return PrayerScheduleEntity(
    date: date,
    hijri: tHijri,
    times: {
      PrayerName.imsak: at(4, 18),
      PrayerName.fajr: at(4, 28),
      PrayerName.sunrise: at(5, 45),
      PrayerName.dhuhr: at(11, 49),
      PrayerName.asr: at(15, 1),
      PrayerName.maghrib: at(17, 50),
      PrayerName.isha: at(18, 59),
    },
  );
}

void main() {
  late MockGetLocation getLocation;
  late MockGetPrayerSchedules getSchedules;

  setUpAll(() {
    registerFallbackValue(tLocation);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    getLocation = MockGetLocation();
    getSchedules = MockGetPrayerSchedules();
    when(() => getSchedules(any(), any(), days: any(named: 'days'))).thenAnswer(
      (invocation) {
        final start = invocation.positionalArguments[1] as DateTime;
        final days = invocation.namedArguments[#days] as int;
        return Right(
          List.generate(
            days,
            (i) => schedule(DateTime(start.year, start.month, start.day + i)),
          ),
        );
      },
    );
  });

  PrayerTimeBloc build(DateTime now) => PrayerTimeBloc(
    getLocation: getLocation,
    getPrayerSchedules: getSchedules,
    clock: () => now,
    tickInterval: const Duration(hours: 1),
  );

  group('PrayerTimeBloc', () {
    blocTest<PrayerTimeBloc, PrayerTimeState>(
      'loads location and today/tomorrow schedules',
      setUp: () => when(
        () => getLocation(refresh: false),
      ).thenAnswer((_) async => const Right(tLocation)),
      build: () => build(DateTime(2026, 9, 16, 16, 40)),
      act: (bloc) => bloc.add(const PrayerTimesRequested()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state.status, PrayerTimeStatus.loaded);
        expect(state.nextPrayer!.prayer, PrayerName.maghrib);
        expect(state.currentPrayer, PrayerName.asr);
      },
    );

    blocTest<PrayerTimeBloc, PrayerTimeState>(
      'rolls over to tomorrow fajr after isha',
      setUp: () => when(
        () => getLocation(refresh: false),
      ).thenAnswer((_) async => const Right(tLocation)),
      build: () => build(DateTime(2026, 9, 16, 21, 0)),
      act: (bloc) => bloc.add(const PrayerTimesRequested()),
      verify: (bloc) {
        final next = bloc.state.nextPrayer!;
        expect(next.prayer, PrayerName.fajr);
        expect(next.time, DateTime(2026, 9, 17, 4, 28));
      },
    );

    blocTest<PrayerTimeBloc, PrayerTimeState>(
      'keeps the schedule and reports a message when refresh fails',
      setUp: () {
        when(
          () => getLocation(refresh: false),
        ).thenAnswer((_) async => const Right(tLocation));
        when(
          () => getLocation(refresh: true),
        ).thenAnswer((_) async => Left(Failure('Location permission denied')));
      },
      build: () => build(DateTime(2026, 9, 16, 9, 0)),
      act: (bloc) async {
        bloc.add(const PrayerTimesRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PrayerTimesRequested(refreshLocation: true));
      },
      verify: (bloc) {
        expect(bloc.state.status, PrayerTimeStatus.loaded);
        expect(bloc.state.today, isNotNull);
        expect(bloc.state.message, 'Location permission denied');
      },
    );
  });

  group('CalendarBloc', () {
    blocTest<CalendarBloc, CalendarState>(
      'loads the whole month and selects the initial day',
      build: () => CalendarBloc(getPrayerSchedules: getSchedules),
      act: (bloc) => bloc.add(
        CalendarStarted(
          location: tLocation,
          initialDate: DateTime(2026, 9, 16, 8),
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.schedules.length, 30);
        expect(bloc.state.selectedSchedule!.date, DateTime(2026, 9, 16));
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'clamps the selected day when moving to a shorter month',
      build: () => CalendarBloc(getPrayerSchedules: getSchedules),
      act: (bloc) async {
        bloc.add(
          CalendarStarted(
            location: tLocation,
            initialDate: DateTime(2026, 1, 31),
          ),
        );
        bloc.add(const CalendarMonthChanged(1));
      },
      verify: (bloc) {
        expect(bloc.state.month, DateTime(2026, 2));
        expect(bloc.state.schedules.length, 28);
        expect(bloc.state.selectedDate, DateTime(2026, 2, 28));
      },
    );

    blocTest<CalendarBloc, CalendarState>(
      'selects a tapped day',
      build: () => CalendarBloc(getPrayerSchedules: getSchedules),
      act: (bloc) async {
        bloc.add(
          CalendarStarted(
            location: tLocation,
            initialDate: DateTime(2026, 9, 1),
          ),
        );
        bloc.add(CalendarDaySelected(DateTime(2026, 9, 20, 13)));
      },
      verify: (bloc) =>
          expect(bloc.state.selectedSchedule!.date, DateTime(2026, 9, 20)),
    );
  });
}
