import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<EditionEntity>>> getQori();
  Future<Either<Failure, List<EditionEntity>>> searchQori();
  Future<Either<Failure, List<SurahEntity>>> getAllSurah();
  Future<Either<Failure, SurahEntity>> getSurah();
  Future<Either<Failure, List<SurahEntity>>> searchSurah();
}
