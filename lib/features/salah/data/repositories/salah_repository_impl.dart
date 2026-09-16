import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/salah/data/datasources/salah_local_datasource.dart';
import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';
import 'package:quran_audio/features/salah/domain/repositories/salah_repository.dart';

class SalahRepositoryImpl implements SalahRepository {
  final SalahLocalDataSource localDataSource;

  SalahRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, SalahGuideEntity>> getGuide() async {
    try {
      final guide = await localDataSource.getGuide();
      return Right(guide.toEntity());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }
}
