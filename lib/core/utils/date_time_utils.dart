import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String time(DateTime time) => DateFormat('HH:mm').format(time);

  static String fullDate(DateTime date) =>
      DateFormat('EEEE, d MMMM y').format(date);

  static String shortDate(DateTime date) => DateFormat('d MMM y').format(date);

  static String monthYear(DateTime date) => DateFormat('MMMM y').format(date);

  /// "2h 05m", "12m" or "now".
  static String countdown(Duration duration) {
    if (duration.inMinutes < 1) return 'now';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
