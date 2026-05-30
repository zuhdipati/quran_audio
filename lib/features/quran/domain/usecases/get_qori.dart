import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';

class GetAllEdition {
  final QuranRepository repository;

  GetAllEdition(this.repository);

  Future<Either<Failure, List<EditionEntity>>> call() {
    return repository.getAllEdition();
  }
}
