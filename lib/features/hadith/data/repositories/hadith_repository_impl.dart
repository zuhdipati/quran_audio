import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_local_datasource.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_remote_datasource.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithLocalDataSource localDataSource;
  final HadithRemoteDataSource remoteDataSource;

  HadithRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<HadithCollectionEntity>>> getCollections() async {
    try {
      final collections = await localDataSource.getCollections();
      return Right(collections.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, HadithPageEntity>> getPage(
    HadithCollectionEntity collection,
    int chunk,
  ) async {
    try {
      final hadiths = collection.bundled
          ? await localDataSource.getBundledHadiths()
          : await _hostedChunk(collection.id, chunk);

      return Right(
        HadithPageEntity(
          collectionId: collection.id,
          chunk: chunk,
          hadiths: hadiths
              .map((e) => e.toEntity(source: collection.name))
              .toList(),
        ),
      );
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }

  /// Cache first: a chunk is immutable once fetched, so there is nothing to
  /// revalidate and offline reads cost no network at all.
  Future<List<HadithModel>> _hostedChunk(String collectionId, int chunk) async {
    final cached = await localDataSource.readChunk(collectionId, chunk);
    if (cached != null && cached.isNotEmpty) return cached;

    final fetched = await remoteDataSource.getChunk(collectionId, chunk);
    await localDataSource.cacheChunk(collectionId, chunk, fetched);
    return fetched;
  }
}
