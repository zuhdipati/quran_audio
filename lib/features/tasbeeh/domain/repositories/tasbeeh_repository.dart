import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';

abstract class TasbeehRepository {
  Future<Either<Failure, List<DzikirEntity>>> getDzikirList();
  Future<Map<String, int>> getCounts();
  Future<void> saveCount(String dzikirId, int count);
}
