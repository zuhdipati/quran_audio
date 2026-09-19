import 'package:intl/intl.dart';
import 'package:quran_audio/l10n/app_localizations.dart';

/// Date formatting follows `Intl.defaultLocale`, which the app root keeps in
/// step with the active language, so month and weekday names localise
/// without every caller threading a locale through.
class DateTimeUtils {
  DateTimeUtils._();

  static String time(DateTime time) => DateFormat('HH:mm').format(time);

  static String fullDate(DateTime date) =>
      DateFormat('EEEE, d MMMM y').format(date);

  static String shortDate(DateTime date) => DateFormat('d MMM y').format(date);

  static String monthYear(DateTime date) => DateFormat('MMMM y').format(date);

  /// "in 2h 05m", "in 12m", or "now" once under a minute.
  ///
  /// Returns the whole phrase rather than just the span: callers used to
  /// wrap the span in "in …", which produced "in now" right before a prayer.
  static String countdown(Duration duration, AppLocalizations l10n) {
    if (duration.inMinutes < 1) return l10n.startingNow;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final span = hours == 0
        ? l10n.durationMinutes(minutes)
        : l10n.durationHoursMinutes(hours, minutes.toString().padLeft(2, '0'));
    return l10n.inDuration(span);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
