import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late EditionBloc editionBloc;
  late MockGetAllEdition mockGetAllEdition;

  setUp(() {
    mockGetAllEdition = MockGetAllEdition();
    editionBloc = EditionBloc(getAllEdition: mockGetAllEdition);
  });

  test('initial state should be EditionInitial', () {
    expect(editionBloc.state, equals(EditionInitial()));
  });

  blocTest<EditionBloc, EditionState>(
    'should emit [EditionLoading, EditionLoaded] when data is gotten successfully',
    build: () {
      when(() => mockGetAllEdition.call())
          .thenAnswer((_) async => Right(tEditionEntityList));
      return editionBloc;
    },
    act: (bloc) => bloc.add(GetEditions()),
    expect: () => [
      EditionLoading(),
      EditionLoaded(allEditions: tEditionEntityList, filteredEditions: tEditionEntityList),
    ],
    verify: (bloc) {
      verify(() => mockGetAllEdition.call());
    },
  );

  blocTest<EditionBloc, EditionState>(
    'should emit [EditionLoading, EditionError] when getting data fails',
    build: () {
      when(() => mockGetAllEdition.call())
          .thenAnswer((_) async => Left(Failure('Server Failure')));
      return editionBloc;
    },
    act: (bloc) => bloc.add(GetEditions()),
    expect: () => [
      EditionLoading(),
      EditionError('Server Failure'),
    ],
    verify: (bloc) {
      verify(() => mockGetAllEdition.call());
    },
  );

  blocTest<EditionBloc, EditionState>(
    'should filter editions properly when SearchEditions is added',
    build: () {
      return editionBloc;
    },
    seed: () => EditionLoaded(allEditions: tEditionEntityList, filteredEditions: tEditionEntityList),
    act: (bloc) => bloc.add(SearchEditions('alafasy')),
    expect: () => [],
  );

  blocTest<EditionBloc, EditionState>(
    'should return empty filtered list when search query does not match',
    build: () {
      return editionBloc;
    },
    seed: () => EditionLoaded(allEditions: tEditionEntityList, filteredEditions: tEditionEntityList),
    act: (bloc) => bloc.add(SearchEditions('nonexistent')),
    expect: () => [
      EditionLoaded(allEditions: tEditionEntityList, filteredEditions: []),
    ],
  );
}
