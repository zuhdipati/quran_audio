import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';

abstract class SalahRepository {
  Future<Either<Failure, SalahGuideEntity>> getGuide();
}
