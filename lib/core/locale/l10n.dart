import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:quran_audio/core/locale/locale_cubit.dart';
import 'package:quran_audio/l10n/app_localizations.dart';

export 'package:quran_audio/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppLocalizationsX on AppLocalizations {
  /// Localised Hijri month for a 1-based month number. Entities keep their
  /// stored Indonesian `monthName` for the data layer; the UI resolves the
  /// display name here so it follows the active language.
  String hijriMonthName(int month) => hijriMonth('m$month');

  String hijriDate(int day, int month, int year) =>
      '$day ${hijriMonthName(month)} $year H';
}

/// Strings for code that runs outside the widget tree, such as services
/// raising toasts.
///
/// Reads `Intl.defaultLocale`, which the app root keeps in step with the
/// active language. Before the first frame that can still be the raw device
/// locale, and `lookupAppLocalizations` throws for anything unsupported, so
/// it is resolved the same way the app resolves it.
AppLocalizations currentL10n() {
  final tag = Intl.getCurrentLocale();
  final language = tag.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    resolveAppLocale([Locale(language)], AppLocalizations.supportedLocales),
  );
}
