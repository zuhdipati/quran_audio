import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_remote_datasource.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';
import 'package:quran_audio/core/error/error_keys.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithRemoteDataSource remoteDataSource;

  HadithRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HadithCollectionEntity>>> getCollections() =>
      _guard(() async {
        final collections = await remoteDataSource.getCollections();
        return collections.map((e) => e.toEntity()).toList();
      });

  @override
  Future<Either<Failure, HadithPageEntity>> getPage(
    HadithCollectionEntity collection,
    int page,
  ) => _guard(() async {
    final result = await remoteDataSource.getPage(collection.id, page);
    return result.toEntity(source: collection.name);
  });

  @override
  Future<Either<Failure, HadithPageEntity>> search(
    String query, {
    HadithCollectionEntity? collection,
    required int page,
  }) => _guard(() async {
    final result = await remoteDataSource.search(
      query,
      collectionId: collection?.id,
      page: page,
    );
    return result.toEntity(source: collection?.name);
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(ErrorKeys.unexpected));
    }
  }
}
