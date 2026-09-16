import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/dua/data/datasources/dua_local_datasource.dart';
import 'package:quran_audio/features/dua/data/models/dua_model.dart';
import 'package:quran_audio/features/dua/data/repositories/dua_repository_impl.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_daily_dua.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_duas.dart';
import 'package:quran_audio/features/dua/presentation/bloc/daily_dua/daily_dua_bloc.dart';
import 'package:quran_audio/features/dua/presentation/bloc/dua/dua_bloc.dart';

class MockDuaDataSource extends Mock implements DuaLocalDataSource {}

DuaModel dua(int id, String group, String title, {bool daily = false}) =>
    DuaModel(
      id: id,
      group: group,
      title: title,
      arabic: 'اَللّٰهُمَّ',
      latin: 'Allahumma',
      translation: 'Ya Allah $title',
      source: 'HR. Muslim',
      daily: daily,
    );

void main() {
  late MockDuaDataSource dataSource;
  late DuaRepositoryImpl repository;

  final tDuas = [
    dua(1, 'Tidur', 'Doa Sebelum Tidur', daily: true),
    dua(2, 'Makan', 'Doa Sebelum Makan', daily: true),
    dua(3, 'Perjalanan', 'Doa Naik Kendaraan'),
  ];

  setUp(() {
    dataSource = MockDuaDataSource();
    repository = DuaRepositoryImpl(localDataSource: dataSource);
    when(() => dataSource.getDuas()).thenAnswer((_) async => tDuas);
  });

  group('DuaRepository', () {
    test(
      'daily dua is stable within a day and only from the daily set',
      () async {
        final morning = await repository.getDailyDua(DateTime(2026, 9, 16, 5));
        final night = await repository.getDailyDua(DateTime(2026, 9, 16, 23));
        final nextDay = await repository.getDailyDua(DateTime(2026, 9, 17));

        final a = morning.getOrElse(() => throw 'x');
        expect(night.getOrElse(() => throw 'x'), equals(a));
        expect(a.isDaily, isTrue);
        expect(nextDay.getOrElse(() => throw 'x'), isNot(equals(a)));
      },
    );

    test('maps data source errors to a failure', () async {
      when(
        () => dataSource.getDuas(),
      ).thenThrow(GeneralException(message: 'Failed to load duas'));

      final result = await repository.getDuas();

      expect(result.isLeft(), isTrue);
    });
  });

  group('DuaBloc', () {
    blocTest<DuaBloc, DuaState>(
      'loads duas and derives groups in order',
      build: () => DuaBloc(getDuas: GetDuas(repository)),
      act: (bloc) => bloc.add(DuasRequested()),
      verify: (bloc) {
        expect(bloc.state.status, DuaStatus.loaded);
        expect(bloc.state.groups, ['Tidur', 'Makan', 'Perjalanan']);
      },
    );

    blocTest<DuaBloc, DuaState>(
      'combines group filter with search query',
      build: () => DuaBloc(getDuas: GetDuas(repository)),
      act: (bloc) async {
        bloc.add(DuasRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DuaSearchChanged('doa'));
        bloc.add(const DuaGroupSelected('Makan'));
      },
      verify: (bloc) {
        expect(bloc.state.filteredDuas.map((d) => d.id), [2]);
        expect(bloc.state.query, 'doa');
      },
    );
  });

  blocTest<DailyDuaBloc, DailyDuaState>(
    'DailyDuaBloc emits the dua of the day',
    build: () => DailyDuaBloc(getDailyDua: GetDailyDua(repository)),
    act: (bloc) => bloc.add(DailyDuaRequested(DateTime(2026, 9, 16))),
    expect: () => [isA<DailyDuaLoading>(), isA<DailyDuaLoaded>()],
  );
}
