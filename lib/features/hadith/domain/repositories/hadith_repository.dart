import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

abstract class HadithRepository {
  /// The narrator catalogue.
  Future<Either<Failure, List<HadithCollectionEntity>>> getCollections();

  /// One page of a collection; [page] is 1-based.
  Future<Either<Failure, HadithPageEntity>> getPage(
    HadithCollectionEntity collection,
    int page,
  );

  /// Full-text search across every collection, or only [collection] when
  /// given, where a bare number opens that hadith instead.
  Future<Either<Failure, HadithPageEntity>> search(
    String query, {
    HadithCollectionEntity? collection,
    required int page,
  });
}
