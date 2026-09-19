import 'package:hijri/hijri_calendar.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/hijri/data/models/islamic_event_model.dart';
import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/core/error/error_keys.dart';

const String islamicEventsAsset = 'assets/data/islamic_events.json';

const List<String> hijriMonthNames = [
  'Muharram',
  'Safar',
  'Rabiul Awal',
  'Rabiul Akhir',
  'Jumadil Awal',
  'Jumadil Akhir',
  'Rajab',
  "Sya'ban",
  'Ramadhan',
  'Syawal',
  "Dzulqa'dah",
  'Dzulhijjah',
];

const List<String> hijriMonthNamesArabic = [
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع الأَوَّل',
  'رَبِيع الآخِر',
  'جُمَادَى الأُولَى',
  'جُمَادَى الآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو القَعْدَة',
  'ذُو الحِجَّة',
];

abstract class HijriLocalDataSource {
  HijriDateEntity toHijri(DateTime date);
  DateTime toGregorian(int year, int month, int day);
  int daysInMonth(int year, int month);
  Future<List<IslamicEventModel>> getEvents();
}

/// Umm al-Qura based conversion, fully offline.
class HijriLocalDataSourceImpl implements HijriLocalDataSource {
  final AssetJsonLoader loader;

  HijriLocalDataSourceImpl({required this.loader});

  @override
  HijriDateEntity toHijri(DateTime date) {
    final hijri = HijriCalendar.fromDate(
      DateTime(date.year, date.month, date.day),
    );
    return HijriDateEntity(
      day: hijri.hDay,
      month: hijri.hMonth,
      year: hijri.hYear,
      monthName: hijriMonthNames[hijri.hMonth - 1],
      monthNameArabic: hijriMonthNamesArabic[hijri.hMonth - 1],
    );
  }

  @override
  DateTime toGregorian(int year, int month, int day) {
    final date = HijriCalendar().hijriToGregorian(year, month, day);
    return DateTime(date.year, date.month, date.day);
  }

  @override
  int daysInMonth(int year, int month) {
    return HijriCalendar().getDaysInMonth(year, month);
  }

  @override
  Future<List<IslamicEventModel>> getEvents() async {
    try {
      final List<dynamic> data = await loader.load(islamicEventsAsset);
      return data.map((e) => IslamicEventModel.fromJson(e)).toList();
    } catch (e) {
      throw GeneralException(message: ErrorKeys.loadIslamicEvents);
    }
  }
}
