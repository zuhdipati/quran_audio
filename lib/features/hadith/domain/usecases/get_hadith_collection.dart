import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';

class GetHadithCollections {
  final HadithRepository repository;

  GetHadithCollections(this.repository);

  Future<Either<Failure, List<HadithCollectionEntity>>> call() =>
      repository.getCollections();
}

class GetHadithPage {
  final HadithRepository repository;

  GetHadithPage(this.repository);

  Future<Either<Failure, HadithPageEntity>> call(
    HadithCollectionEntity collection,
    int chunk,
  ) => repository.getPage(collection, chunk);
}
