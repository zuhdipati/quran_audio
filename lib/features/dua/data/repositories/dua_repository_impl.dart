import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/dua/data/datasources/dua_local_datasource.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/domain/repositories/dua_repository.dart';
import 'package:quran_audio/core/error/error_keys.dart';

class DuaRepositoryImpl implements DuaRepository {
  final DuaLocalDataSource localDataSource;

  DuaRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<DuaEntity>>> getDuas() async {
    try {
      final duas = await localDataSource.getDuas();
      return Right(duas.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(ErrorKeys.unexpected));
    }
  }

  @override
  Future<Either<Failure, DuaEntity>> getDailyDua(DateTime date) async {
    try {
      final duas = await localDataSource.getDuas();
      final daily = duas.where((e) => e.daily).toList();
      final pool = daily.isEmpty ? duas : daily;
      if (pool.isEmpty) return Left(Failure(ErrorKeys.noDua));

      final dayIndex = DateTime.utc(
        date.year,
        date.month,
        date.day,
      ).difference(DateTime.utc(2024)).inDays;
      return Right(pool[dayIndex % pool.length].toEntity());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(ErrorKeys.unexpected));
    }
  }
}
