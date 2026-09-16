import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/tasbeeh/data/datasources/tasbeeh_local_datasource.dart';
import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';
import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';

class TasbeehRepositoryImpl implements TasbeehRepository {
  final TasbeehLocalDataSource localDataSource;

  TasbeehRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<DzikirEntity>>> getDzikirList() async {
    try {
      final list = await localDataSource.getDzikirList();
      return Right(list.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Future<Map<String, int>> getCounts() async {
    try {
      return await localDataSource.getCounts();
    } catch (e) {
      AppLogger.w('Failed to read tasbeeh counts', error: e);
      return {};
    }
  }

  @override
  Future<void> saveCount(String dzikirId, int count) async {
    try {
      await localDataSource.saveCount(dzikirId, count);
    } catch (e) {
      AppLogger.w('Failed to save tasbeeh count', error: e);
    }
  }
}
