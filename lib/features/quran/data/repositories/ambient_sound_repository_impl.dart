import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_file_datasource.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/ambient_sound_repository.dart';
import 'package:quran_audio/core/error/error_keys.dart';

class AmbientSoundRepositoryImpl implements AmbientSoundRepository {
  final AmbientSoundDataSource dataSource;
  final AmbientSoundFileDataSource fileDataSource;

  AmbientSoundRepositoryImpl({
    required this.dataSource,
    required this.fileDataSource,
  });

  @override
  Future<Either<Failure, List<AmbientSoundEntity>>> getAmbientSounds() async {
    try {
      final sounds = await dataSource.getAmbientSounds();
      return Right(sounds.map((e) => e.toEntity()).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(ErrorKeys.unexpected));
    }
  }

  @override
  Future<Either<Failure, String>> getSoundFile(AmbientSoundEntity sound) async {
    try {
      return Right(await fileDataSource.getFile(sound.file));
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(ErrorKeys.playSound));
    }
  }
}
