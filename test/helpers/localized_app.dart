import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quran_audio/l10n/app_localizations.dart';

/// Wraps [home] in a MaterialApp that can resolve `context.l10n`.
///
/// Pinned to English so text assertions don't depend on the locale of the
/// machine running the suite.
MaterialApp localizedApp({required Widget home, Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
