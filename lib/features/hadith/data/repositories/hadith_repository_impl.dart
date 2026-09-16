import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_local_datasource.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithLocalDataSource localDataSource;

  HadithRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, HadithCollectionEntity>> getCollection() async {
    try {
      final collection = await localDataSource.getCollection();
      return Right(collection.toEntity());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }
}
