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
  late GetHadithCollections getCollections;
  late GetHadithPage getPage;

  const arbain = HadithCollectionEntity(
    id: 'arbain-nawawi',
    name: 'Hadits Arbain An-Nawawi',
    narrator: 'Imam An-Nawawi',
    total: 42,
    chunkSize: 42,
    chunks: 1,
    bundled: true,
  );

  const bukhari = HadithCollectionEntity(
    id: 'shahih-bukhari',
    name: 'Shahih Bukhari',
    narrator: 'Imam Bukhari',
    total: 300,
    chunkSize: 100,
    chunks: 3,
  );

  const collections = [arbain, bukhari];

  List<HadithEntity> page(int chunk, {int size = 100}) => List.generate(
    size,
    (i) => HadithEntity(
      number: (chunk - 1) * size + i + 1,
      arabic: 'عربي',
      translation: 'terjemahan ${(chunk - 1) * size + i + 1}',
    ),
  );

  HadithPageEntity pageOf(String id, int chunk, {int size = 100}) =>
      HadithPageEntity(
        collectionId: id,
        chunk: chunk,
        hadiths: page(chunk, size: size),
      );

  setUpAll(() {
    registerFallbackValue(arbain);
  });

  setUp(() {
    repository = MockHadithRepository();
    getCollections = GetHadithCollections(repository);
    getPage = GetHadithPage(repository);
  });

  HadithBloc build() => HadithBloc(
    getHadithCollections: getCollections,
    getHadithPage: getPage,
  );

  void stubCollections() {
    when(
      () => repository.getCollections(),
    ).thenAnswer((_) async => const Right(collections));
  }

  group('HadithsRequested', () {
    blocTest<HadithBloc, HadithState>(
      'opens the bundled collection first so the page fills offline',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
      },
      build: build,
      act: (bloc) => bloc.add(const HadithsRequested()),
      verify: (bloc) {
        expect(bloc.state.status, HadithStatus.loaded);
        expect(bloc.state.selected, arbain);
        expect(bloc.state.hadiths.length, 42);
        expect(bloc.state.loadedChunks, 1);
        expect(bloc.state.hasMore, isFalse);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'reports the failure when the manifest cannot be read',
      setUp: () => when(
        () => repository.getCollections(),
      ).thenAnswer((_) async => Left(Failure('boom'))),
      build: build,
      act: (bloc) => bloc.add(const HadithsRequested()),
      verify: (bloc) {
        expect(bloc.state.status, HadithStatus.error);
        expect(bloc.state.message, 'boom');
      },
    );
  });

  group('HadithCollectionSelected', () {
    blocTest<HadithBloc, HadithState>(
      'switching narrator resets the list and reloads from chunk one',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
        when(
          () => repository.getPage(bukhari, 1),
        ).thenAnswer((_) async => Right(pageOf(bukhari.id, 1)));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithCollectionSelected(bukhari));
      },
      verify: (bloc) {
        expect(bloc.state.selected, bukhari);
        expect(bloc.state.hadiths.length, 100);
        expect(bloc.state.hadiths.first.number, 1);
        expect(bloc.state.loadedChunks, 1);
        expect(bloc.state.hasMore, isTrue);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'reselecting the open collection does not refetch',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithCollectionSelected(arbain));
      },
      verify: (_) => verify(() => repository.getPage(arbain, 1)).called(1),
    );
  });

  group('HadithNextPageRequested', () {
    blocTest<HadithBloc, HadithState>(
      'appends the next chunk in order',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
        when(
          () => repository.getPage(bukhari, any()),
        ).thenAnswer((invocation) async {
          final chunk = invocation.positionalArguments[1] as int;
          return Right(pageOf(bukhari.id, chunk));
        });
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithCollectionSelected(bukhari));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithNextPageRequested());
      },
      verify: (bloc) {
        expect(bloc.state.hadiths.length, 200);
        expect(bloc.state.hadiths.last.number, 200);
        expect(bloc.state.loadedChunks, 2);
        expect(bloc.state.loadingMore, isFalse);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'stops at the end of the collection',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithNextPageRequested());
      },
      verify: (_) => verifyNever(() => repository.getPage(arbain, 2)),
    );

    blocTest<HadithBloc, HadithState>(
      'a failed chunk keeps what is already loaded',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
        when(
          () => repository.getPage(bukhari, 1),
        ).thenAnswer((_) async => Right(pageOf(bukhari.id, 1)));
        when(
          () => repository.getPage(bukhari, 2),
        ).thenAnswer((_) async => Left(Failure('offline')));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithCollectionSelected(bukhari));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithNextPageRequested());
      },
      verify: (bloc) {
        expect(bloc.state.hadiths.length, 100);
        expect(bloc.state.loadedChunks, 1);
        expect(bloc.state.loadingMore, isFalse);
        expect(bloc.state.message, 'offline');
        expect(bloc.state.hasMore, isTrue);
      },
    );
  });

  group('search', () {
    blocTest<HadithBloc, HadithState>(
      'filters only what has been loaded',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithSearchChanged('terjemahan 7'));
      },
      verify: (bloc) {
        expect(bloc.state.hadiths.length, 42);
        expect(bloc.state.visible.map((h) => h.number), [7]);
      },
    );

    blocTest<HadithBloc, HadithState>(
      'an empty query restores the full loaded list',
      setUp: () {
        stubCollections();
        when(() => repository.getPage(arbain, 1)).thenAnswer(
          (_) async => Right(pageOf(arbain.id, 1, size: 42)),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HadithsRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HadithSearchChanged('terjemahan 7'));
        bloc.add(const HadithSearchChanged(''));
      },
      verify: (bloc) => expect(bloc.state.visible.length, 42),
    );
  });
}
