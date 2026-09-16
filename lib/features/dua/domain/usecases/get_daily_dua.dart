import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/domain/repositories/dua_repository.dart';

class GetDailyDua {
  final DuaRepository repository;

  GetDailyDua(this.repository);

  Future<Either<Failure, DuaEntity>> call(DateTime date) =>
      repository.getDailyDua(date);
}
