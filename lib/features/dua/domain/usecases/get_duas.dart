import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/domain/repositories/dua_repository.dart';

class GetDuas {
  final DuaRepository repository;

  GetDuas(this.repository);

  Future<Either<Failure, List<DuaEntity>>> call() => repository.getDuas();
}
