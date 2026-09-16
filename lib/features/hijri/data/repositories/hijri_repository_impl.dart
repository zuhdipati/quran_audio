import 'package:dartz/dartz.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/hijri/data/models/islamic_event_model.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_month_entity.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';
import 'package:quran_audio/features/hijri/domain/repositories/hijri_repository.dart';

class HijriRepositoryImpl implements HijriRepository {
  final HijriLocalDataSource localDataSource;

  HijriRepositoryImpl({required this.localDataSource});

  @override
  HijriDateEntity toHijri(DateTime date) => localDataSource.toHijri(date);

  @override
  Future<Either<Failure, HijriMonthEntity>> getHijriMonth(
    int year,
    int month,
  ) async {
    try {
      final length = localDataSource.daysInMonth(year, month);
      final days = List.generate(length, (index) {
        final gregorian = localDataSource.toGregorian(year, month, index + 1);
        return HijriDayEntity(
          hijri: HijriDateEntity(
            day: index + 1,
            month: month,
            year: year,
            monthName: hijriMonthNames[month - 1],
            monthNameArabic: hijriMonthNamesArabic[month - 1],
          ),
          gregorian: gregorian,
        );
      });

      final events = await localDataSource.getEvents();
      final monthEvents = events
          .where((e) => e.month == month && e.day <= length)
          .map((e) => _toEntity(e, year))
          .toList();

      return Right(
        HijriMonthEntity(
          year: year,
          month: month,
          monthName: hijriMonthNames[month - 1],
          monthNameArabic: hijriMonthNamesArabic[month - 1],
          days: days,
          events: monthEvents,
        ),
      );
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Hijri date is out of supported range'));
    }
  }

  @override
  Future<Either<Failure, List<IslamicEventEntity>>> getUpcomingEvents(
    DateTime from, {
    int limit = 5,
  }) async {
    try {
      final today = DateTime(from.year, from.month, from.day);
      final hijriToday = localDataSource.toHijri(today);
      final events = await localDataSource.getEvents();

      final upcoming = <IslamicEventEntity>[];
      for (final year in [hijriToday.year, hijriToday.year + 1]) {
        for (final event in events) {
          final entity = _toEntity(event, year);
          if (!entity.gregorian.isBefore(today)) upcoming.add(entity);
        }
      }
      upcoming.sort((a, b) => a.gregorian.compareTo(b.gregorian));
      return Right(upcoming.take(limit).toList());
    } on GeneralException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Failed to load Islamic events'));
    }
  }

  IslamicEventEntity _toEntity(IslamicEventModel model, int year) {
    return IslamicEventEntity(
      name: model.name,
      description: model.description,
      hijriMonth: model.month,
      hijriDay: model.day,
      hijriYear: year,
      gregorian: localDataSource.toGregorian(year, model.month, model.day),
    );
  }
}
