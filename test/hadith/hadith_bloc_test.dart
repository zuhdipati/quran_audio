import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';
import 'package:quran_audio/features/hadith/domain/usecases/get_hadith_collection.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';

class MockHadithRepository extends Mock implements HadithRepository {}

void main() {
  late MockHadithRepository repository;

  const arbain = HadithCollectionEntity(
    id: 'arbain-nawawi',
    name: 'Hadits Arbain An-Nawawi',
    narrator: 'Imam An-Nawawi',
    total: 42,
  );

  const bukhari = HadithCollectionEntity(
    id: 'shahih-bukhari',
    name: 'Shahih Bukhari',
    narrator: 'Imam Bukhari',
    total: 7008,
  );

  const collections = [arbain, bukhari];

  /// Page [page] of 20, numbered as the API numbers them.
  HadithPageEntity pageOf(int page, {int total = 7008}) => HadithPageEntity(
    page: page,
    totalPages: (total / 20).ceil(),
    total: total,
    hadiths: List.generate(
      20,
      (i) => HadithEntity(
        number: (page - 1) * 20 + i + 1,
        arabic: 'عربي',
        translation: 'terjemahan',
      ),
    ),
  );

  const results = HadithPageEntity(
    page: 1,
    totalPages: 1,
    total: 1,
    hadiths: [
      HadithEntity(
        number: 1203,
        arabic: 'عربي',
        translation: 'Sesungguhnya sabar itu',
        source: 'Shahih Bukhari',
        snippet: 'Sesungguhnya <mark>sabar</mark> itu',
      ),
    ],
  );

  // past the bloc's debounce, so the search has gone out
  const settle = Duration(milliseconds: 450);

  setUpAll(() => registerFallbackValue(arbain));

  setUp(() {
    repository = MockHadithRepository();
    when(
      () => repository.getCollections(),
    ).thenAnswer((_) async => const Right(collections));
    when(() => repository.getPage(arbain, any())).thenAnswer(
      (i) async => Right(pageOf(i.positionalArguments[1], total: 42)),
    );
    when(
      () => repository.getPage(bukhari, any()),
    ).thenAnswer((i) async => Right(pageOf(i.positionalArguments[1])));
    when(
      () => repository.search(
        any(),
        collection: any(named: 'collection'),
        page: any(named: 'page'),
      ),
    ).thenAnswer((_) async => const Right(results));
  });

  HadithBloc build() => HadithBloc(
    getHadithCollections: GetHadithCollections(repository),
    getHadithPage: GetHadithPage(repository),
    searchHadith: SearchHadith(repository),
  );

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  group('HadithsRequested', () {
    blocTest<HadithBloc, HadithState>(
      'opens page 1 of the first collection',
      build: build,
      act: (bloc) => bloc.add(const HadithsRequested()),
      verify: (bloc) {
        expect(bloc.state.status, HadithStatus.loaded);
        expect(bloc.state.selected, arbain);
        expect(bloc.state.pageNumber, 1);
        expect(bloc.state.page?.totalPages, 3);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'reports the failure when the catalogue cannot be read',
      setUp: () => when(
        () => repository.getCollections(),
      ).thenAnswer((_) async => Left(Failure('noInternet'))),
      build: build,
      act: (bloc) => bloc.add(const HadithsRequested()),
      verify: (bloc) {
        expect(bloc.state.status, HadithStatus.error);
        expect(bloc.state.collections, isEmpty);
        expect(bloc.state.message, 'noInternet');
      },
    );
  });

  group('paging', () {
    blocTest<HadithBloc, HadithState>(
      'jumps straight to any page',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithCollectionSelected(bukhari));
        await tick();
        bloc.add(const HadithPageRequested(351));
      },
      verify: (bloc) {
        expect(bloc.state.pageNumber, 351);
        expect(bloc.state.page?.hadiths.first.number, 7001);
        verifyNever(() => repository.getPage(bukhari, 2));
      },
    );

    blocTest<HadithBloc, HadithState>(
      'a failed page keeps the previous one for the pager and can be retried',
      setUp: () => when(
        () => repository.getPage(arbain, 2),
      ).thenAnswer((_) async => Left(Failure('timeout'))),
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithPageRequested(2));
      },
      verify: (bloc) {
        expect(bloc.state.status, HadithStatus.error);
        expect(bloc.state.message, 'timeout');
        expect(bloc.state.pageNumber, 2);
        expect(bloc.state.page?.page, 1);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'a slow page never replaces a newer one',
      setUp: () {
        final slow = Completer<Either<Failure, HadithPageEntity>>();
        when(
          () => repository.getPage(bukhari, 2),
        ).thenAnswer((_) => slow.future);
        // page 2 answers only after page 3 has landed
        when(() => repository.getPage(bukhari, 3)).thenAnswer((_) async {
          scheduleMicrotask(() => slow.complete(Right(pageOf(2))));
          return Right(pageOf(3));
        });
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithCollectionSelected(bukhari));
        await tick();
        bloc.add(const HadithPageRequested(2));
        bloc.add(const HadithPageRequested(3));
        await tick();
      },
      verify: (bloc) {
        expect(bloc.state.pageNumber, 3);
        expect(bloc.state.page?.page, 3);
      },
    );
  });

  group('HadithCollectionSelected', () {
    blocTest<HadithBloc, HadithState>(
      'starts the new collection at page 1',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithPageRequested(2));
        await tick();
        bloc.add(const HadithCollectionSelected(bukhari));
      },
      verify: (bloc) {
        expect(bloc.state.selected, bukhari);
        expect(bloc.state.pageNumber, 1);
        expect(bloc.state.page?.totalPages, 351);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'reselecting the open collection does not refetch',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithCollectionSelected(arbain));
      },
      verify: (_) => verify(() => repository.getPage(arbain, 1)).called(1),
    );
  });

  group('search', () {
    blocTest<HadithBloc, HadithState>(
      'searches the open collection once typing pauses',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithSearchChanged('sa'));
        bloc.add(const HadithSearchChanged('sab'));
        bloc.add(const HadithSearchChanged(' sabar '));
      },
      wait: settle,
      verify: (bloc) {
        expect(bloc.state.query, 'sabar');
        expect(bloc.state.page, results);
        verify(
          () => repository.search('sabar', collection: arbain, page: 1),
        ).called(1);
        verifyNever(
          () => repository.search(
            'sab',
            collection: any(named: 'collection'),
            page: any(named: 'page'),
          ),
        );
      },
    );

    blocTest<HadithBloc, HadithState>(
      'the all-collections scope searches without a collection',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithSearchChanged('sabar'));
        await Future<void>.delayed(settle);
        bloc.add(const HadithSearchScopeChanged(searchAll: true));
      },
      wait: settle,
      verify: (bloc) {
        expect(bloc.state.searchAll, isTrue);
        verify(
          () => repository.search('sabar', collection: null, page: 1),
        ).called(1);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'clearing the query returns to the page being browsed',
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await tick();
        bloc.add(const HadithCollectionSelected(bukhari));
        await tick();
        bloc.add(const HadithPageRequested(120));
        await tick();
        bloc.add(const HadithSearchChanged('sabar'));
        await Future<void>.delayed(settle);
        bloc.add(const HadithSearchChanged(''));
      },
      wait: settle,
      verify: (bloc) {
        expect(bloc.state.searching, isFalse);
        expect(bloc.state.pageNumber, 120);
        expect(bloc.state.page?.hadiths.first.number, 2381);
      },
    );
  });
}
