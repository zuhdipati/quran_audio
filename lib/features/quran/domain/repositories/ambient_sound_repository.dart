import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';

abstract class AmbientSoundRepository {
  Future<Either<Failure, List<AmbientSoundEntity>>> getAmbientSounds();

  /// A local file path for [sound], downloaded on first use.
  Future<Either<Failure, String>> getSoundFile(AmbientSoundEntity sound);
}
