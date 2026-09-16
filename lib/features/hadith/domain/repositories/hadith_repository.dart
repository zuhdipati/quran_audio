import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

abstract class HadithRepository {
  /// The narrator catalogue, read from the bundled manifest.
  Future<Either<Failure, List<HadithCollectionEntity>>> getCollections();

  /// One page of a collection: bundled collections read from assets, the
  /// rest from the cache, falling back to the network.
  Future<Either<Failure, HadithPageEntity>> getPage(
    HadithCollectionEntity collection,
    int chunk,
  );
}
