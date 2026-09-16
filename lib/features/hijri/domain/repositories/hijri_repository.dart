import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_month_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';

abstract class HijriRepository {
  HijriDateEntity toHijri(DateTime date);
  Future<Either<Failure, HijriMonthEntity>> getHijriMonth(int year, int month);
  Future<Either<Failure, List<IslamicEventEntity>>> getUpcomingEvents(
    DateTime from, {
    int limit = 5,
  });
}
