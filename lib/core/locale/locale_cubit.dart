import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// The user's language choice, persisted across launches.
///
/// `null` means follow the device, resolved by [resolveAppLocale].
class LocaleCubit extends Cubit<Locale?> {
  static const storageKey = 'locale';

  final Box box;

  LocaleCubit({required this.box}) : super(_read(box));

  static Locale? _read(Box box) {
    final code = box.get(storageKey);
    return code is String && code.isNotEmpty ? Locale(code) : null;
  }

  Future<void> select(Locale? locale) async {
    if (locale == null) {
      await box.delete(storageKey);
    } else {
      await box.put(storageKey, locale.languageCode);
    }
    emit(locale);
  }
}

/// Picks the first device language the app ships, in the device's order of
/// preference. Anything unsupported falls back to Indonesian rather than
/// English, because that is the language the app's content is written in.
Locale resolveAppLocale(
  List<Locale>? deviceLocales,
  Iterable<Locale> supported,
) {
  for (final device in deviceLocales ?? const <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == device.languageCode) return candidate;
    }
  }
  return const Locale('id');
}
