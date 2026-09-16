import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';
import 'package:quran_audio/features/salah/domain/repositories/salah_repository.dart';

class GetSalahGuide {
  final SalahRepository repository;

  GetSalahGuide(this.repository);

  Future<Either<Failure, SalahGuideEntity>> call() => repository.getGuide();
}
