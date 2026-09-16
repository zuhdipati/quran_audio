import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';

class GetHadithCollection {
  final HadithRepository repository;

  GetHadithCollection(this.repository);

  Future<Either<Failure, HadithCollectionEntity>> call() =>
      repository.getCollection();
}
