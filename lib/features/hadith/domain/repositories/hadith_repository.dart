import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

abstract class HadithRepository {
  Future<Either<Failure, HadithCollectionEntity>> getCollection();
}
