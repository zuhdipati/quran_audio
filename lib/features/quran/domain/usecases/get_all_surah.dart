import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';

class GetAllSurah {
  final QuranRepository repository;

  GetAllSurah(this.repository);

  Future<Either<Failure, List<SurahEntity>>> call(String edition) {
    return repository.getAllSurah(edition);
  }
}
