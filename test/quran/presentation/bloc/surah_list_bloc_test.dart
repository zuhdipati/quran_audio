import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late SurahListBloc surahListBloc;
  late MockGetAllSurah mockGetAllSurah;

  setUp(() {
    mockGetAllSurah = MockGetAllSurah();
    surahListBloc = SurahListBloc(getAllSurah: mockGetAllSurah);
  });

  test('initial state should be SurahListInitial', () {
    expect(surahListBloc.state, equals(SurahListInitial()));
  });

  blocTest<SurahListBloc, SurahListState>(
    'should emit [SurahListLoading, SurahListLoaded] when data is gotten successfully',
    build: () {
      when(() => mockGetAllSurah.call(tEditionEntity.identifier))
          .thenAnswer((_) async => Right(tSurahEntityList));
      return surahListBloc;
    },
    act: (bloc) => bloc.add(FetchSurahs(tEditionEntity)),
    expect: () => [
      SurahListLoading(currentEdition: tEditionEntity),
      SurahListLoaded(allSurahs: tSurahEntityList, filteredSurahs: tSurahEntityList, currentEdition: tEditionEntity),
    ],
    verify: (bloc) {
      verify(() => mockGetAllSurah.call(tEditionEntity.identifier));
    },
  );

  blocTest<SurahListBloc, SurahListState>(
    'should emit [SurahListLoading, SurahListError] when getting data fails',
    build: () {
      when(() => mockGetAllSurah.call(tEditionEntity.identifier))
          .thenAnswer((_) async => Left(Failure('Server Failure')));
      return surahListBloc;
    },
    act: (bloc) => bloc.add(FetchSurahs(tEditionEntity)),
    expect: () => [
      SurahListLoading(currentEdition: tEditionEntity),
      SurahListError('Server Failure'),
    ],
    verify: (bloc) {
      verify(() => mockGetAllSurah.call(tEditionEntity.identifier));
    },
  );

  blocTest<SurahListBloc, SurahListState>(
    'should filter surahs properly when SearchSurahs is added',
    build: () {
      return surahListBloc;
    },
    seed: () => SurahListLoaded(allSurahs: tSurahEntityList, filteredSurahs: tSurahEntityList, currentEdition: tEditionEntity),
    act: (bloc) => bloc.add(SearchSurahs('faatiha')),
    expect: () => [],
  );

  blocTest<SurahListBloc, SurahListState>(
    'should return empty filtered list when search query does not match',
    build: () {
      return surahListBloc;
    },
    seed: () => SurahListLoaded(allSurahs: tSurahEntityList, filteredSurahs: tSurahEntityList, currentEdition: tEditionEntity),
    act: (bloc) => bloc.add(SearchSurahs('nonexistent')),
    expect: () => [
      SurahListLoaded(allSurahs: tSurahEntityList, filteredSurahs: [], currentEdition: tEditionEntity),
    ],
  );
}
