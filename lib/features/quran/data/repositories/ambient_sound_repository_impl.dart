import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_datasource.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/ambient_sound_repository.dart';

class AmbientSoundRepositoryImpl implements AmbientSoundRepository {
  final AmbientSoundDataSource dataSource;

  AmbientSoundRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<AmbientSoundEntity>>> getAmbientSounds() async {
    try {
      final sounds = await dataSource.getAmbientSounds();
      return Right(sounds.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('An unexpected error occurred'));
    }
  }
}
