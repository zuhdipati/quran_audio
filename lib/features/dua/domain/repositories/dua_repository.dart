import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';

abstract class DuaRepository {
  Future<Either<Failure, List<DuaEntity>>> getDuas();

  /// A dua from the everyday set that stays the same for the whole [date].
  Future<Either<Failure, DuaEntity>> getDailyDua(DateTime date);
}
