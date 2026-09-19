import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_remote_datasource.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';
import 'package:quran_audio/features/hadith/data/repositories/hadith_repository_impl.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

class MockHadithRemoteDataSource extends Mock
    implements HadithRemoteDataSource {}

void main() {
  late MockHadithRemoteDataSource remote;
  late HadithRepositoryImpl repository;

  const bukhari = HadithCollectionEntity(
    id: 'shahih-bukhari',
    name: 'Shahih Bukhari',
    narrator: 'Imam Bukhari',
    total: 7008,
  );

  // shaped like the API's responses, so parsing is covered too
  final pageJson = {
    'data': [
      {
        'number': 41,
        'title': null,
        'arabic': 'حَدَّثَنَا',
        'translation': 'Telah menceritakan kepada kami',
      },
    ],
    'page': 3,
    'limit': 20,
    'total': 7008,
    'totalPages': 351,
  };

  final searchJson = {
    'data': [
      {
        'collection': 'arbain-nawawi',
        'collectionName': 'Hadits Arbain An-Nawawi',
        'number': 23,
        'title': 'Bersuci Sebagian dari Iman',
        'arabic': 'الطُّهُورُ شَطْرُ الْإِيمَانِ',
        'translation': 'Bersuci adalah sebagian dari iman',
        'snippet': '…<mark>sabar</mark> itu dhiya’…',
      },
    ],
    'page': 1,
    'limit': 20,
    'total': 1000,
    'totalPages': 50,
    'capped': true,
  };

  setUp(() {
    remote = MockHadithRemoteDataSource();
    repository = HadithRepositoryImpl(remoteDataSource: remote);
  });

  group('getCollections', () {
    test('maps the catalogue', () async {
      when(() => remote.getCollections()).thenAnswer(
        (_) async => [
          HadithCollectionModel.fromJson({
            'id': 'shahih-bukhari',
            'name': 'Shahih Bukhari',
            'narrator': 'Imam Bukhari',
            'total': 7008,
          }),
        ],
      );

      final result = await repository.getCollections();

      expect(result.getOrElse(() => []), [bukhari]);
    });

    test('passes the datasource error key through', () async {
      when(
        () => remote.getCollections(),
      ).thenThrow(GeneralException(message: ErrorKeys.noInternet));

      final result = await repository.getCollections();

      expect(result.fold((f) => f.message, (_) => null), ErrorKeys.noInternet);
    });

    test('anything else becomes the generic error', () async {
      when(() => remote.getCollections()).thenThrow(StateError('boom'));

      final result = await repository.getCollections();

      expect(result.fold((f) => f.message, (_) => null), ErrorKeys.unexpected);
    });
  });

  group('getPage', () {
    test('keeps the paging and credits the collection', () async {
      when(
        () => remote.getPage('shahih-bukhari', 3),
      ).thenAnswer((_) async => HadithPageModel.fromJson(pageJson));

      final result = await repository.getPage(bukhari, 3);

      final page = result.getOrElse(() => throw 'expected a page');
      expect(page.page, 3);
      expect(page.totalPages, 351);
      expect(page.total, 7008);
      expect(page.capped, isFalse);
      expect(page.hadiths.single.number, 41);
      expect(page.hadiths.single.title, isNull);
      expect(page.hadiths.single.source, 'Shahih Bukhari');
    });

    test('reports failures', () async {
      when(
        () => remote.getPage('shahih-bukhari', 2),
      ).thenThrow(GeneralException(message: ErrorKeys.loadHadiths));

      final result = await repository.getPage(bukhari, 2);

      expect(result.fold((f) => f.message, (_) => null), ErrorKeys.loadHadiths);
    });
  });

  group('search', () {
    test('results name their own collection and keep the snippet', () async {
      when(
        () => remote.search('sabar', collectionId: null, page: 1),
      ).thenAnswer((_) async => HadithPageModel.fromJson(searchJson));

      final result = await repository.search('sabar', page: 1);

      final page = result.getOrElse(() => throw 'expected results');
      expect(page.capped, isTrue);
      expect(page.total, 1000);
      final hit = page.hadiths.single;
      expect(hit.source, 'Hadits Arbain An-Nawawi');
      expect(hit.snippet, '…<mark>sabar</mark> itu dhiya’…');
      expect(hit.title, 'Bersuci Sebagian dari Iman');
    });

    test('scopes to the collection when one is given', () async {
      when(
        () => remote.search('5000', collectionId: 'shahih-bukhari', page: 1),
      ).thenAnswer((_) async => HadithPageModel.fromJson(pageJson));

      await repository.search('5000', collection: bukhari, page: 1);

      verify(
        () => remote.search('5000', collectionId: 'shahih-bukhari', page: 1),
      ).called(1);
    });
  });
}
