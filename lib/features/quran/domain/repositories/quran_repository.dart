import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<EditionEntity>>> getAllEdition();
  Future<Either<Failure, List<SurahEntity>>> getAllSurah(String edition);
  Future<Either<Failure, SurahEntity>> getSurah(
    int surahNumber,
    String edition,
  );
}
