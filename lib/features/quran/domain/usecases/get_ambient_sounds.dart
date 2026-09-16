import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/repositories/ambient_sound_repository.dart';

class GetAmbientSounds {
  final AmbientSoundRepository repository;

  GetAmbientSounds(this.repository);

  Future<Either<Failure, List<AmbientSoundEntity>>> call() =>
      repository.getAmbientSounds();
}
