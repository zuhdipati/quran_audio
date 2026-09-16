import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_month_entity.dart';
import 'package:quran_audio/features/hijri/domain/repositories/hijri_repository.dart';

class GetHijriMonth {
  final HijriRepository repository;

  GetHijriMonth(this.repository);

  Future<Either<Failure, HijriMonthEntity>> call(int year, int month) {
    return repository.getHijriMonth(year, month);
  }
}
