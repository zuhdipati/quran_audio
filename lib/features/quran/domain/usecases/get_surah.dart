import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';

class GetSurah {
  final QuranRepository repository;

  GetSurah(this.repository);

  Future<Either<Failure, SurahEntity>> call(int surahNumber, String edition) {
    return repository.getSurah(surahNumber, edition);
  }
}
