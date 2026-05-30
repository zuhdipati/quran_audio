import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/core/services/network_info.dart';
import 'package:quran_audio/features/quran/data/datasources/local_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/remote_datasource.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;
  final QuranLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  QuranRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EditionEntity>>> getAllEdition() async {
    try {
      if (await networkInfo.hasConnection) {
        final result = await remoteDataSource.getAllEdition();
        await localDataSource.cacheEditions(result);
        return Right(result.map((e) => e.toEntity()).toList());
      } else {
        final cachedResult = await localDataSource.getAllEdition();
        return Right(cachedResult.map((e) => e.toEntity()).toList());
      }
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<SurahEntity>>> getAllSurah(String edition) async {
    try {
      final result = await remoteDataSource.getAllSurah(edition);
      return Right(result.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, SurahEntity>> getSurah(
    int surahNumber,
    String edition,
  ) async {
    try {
      final result = await remoteDataSource.getSurah(surahNumber, edition);
      return Right(result.toEntity());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }
}
