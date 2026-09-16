import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';
import 'package:quran_audio/features/hijri/domain/repositories/hijri_repository.dart';

class GetUpcomingEvents {
  final HijriRepository repository;

  GetUpcomingEvents(this.repository);

  Future<Either<Failure, List<IslamicEventEntity>>> call(
    DateTime from, {
    int limit = 5,
  }) {
    return repository.getUpcomingEvents(from, limit: limit);
  }
}
