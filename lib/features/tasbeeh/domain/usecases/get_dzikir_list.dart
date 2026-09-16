import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';
import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';

class GetDzikirList {
  final TasbeehRepository repository;

  GetDzikirList(this.repository);

  Future<Either<Failure, List<DzikirEntity>>> call() =>
      repository.getDzikirList();
}
