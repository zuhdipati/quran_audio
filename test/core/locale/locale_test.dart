import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/locale/locale_cubit.dart';
import 'package:quran_audio/l10n/app_localizations_en.dart';
import 'package:quran_audio/l10n/app_localizations_id.dart';

class MockBox extends Mock implements Box {}

const _supported = [Locale('en'), Locale('id')];

void main() {
  group('resolveAppLocale', () {
    test('matches the device language', () {
      expect(resolveAppLocale([const Locale('en', 'US')], _supported),
          const Locale('en'));
      expect(resolveAppLocale([const Locale('id', 'ID')], _supported),
          const Locale('id'));
    });

    test('honours the device preference order', () {
      expect(
        resolveAppLocale([const Locale('fr'), const Locale('en')], _supported),
        const Locale('en'),
      );
    });

    test('falls back to Indonesian, the language of the content', () {
      expect(resolveAppLocale([const Locale('fr')], _supported),
          const Locale('id'));
      expect(resolveAppLocale(null, _supported), const Locale('id'));
    });
  });

  group('LocaleCubit', () {
    late MockBox box;

    setUp(() {
      box = MockBox();
      when(() => box.put(any(), any())).thenAnswer((_) async {});
      when(() => box.delete(any())).thenAnswer((_) async {});
    });

    test('follows the device when nothing is saved', () {
      when(() => box.get(LocaleCubit.storageKey)).thenReturn(null);
      expect(LocaleCubit(box: box).state, isNull);
    });

    test('restores a saved choice', () {
      when(() => box.get(LocaleCubit.storageKey)).thenReturn('en');
      expect(LocaleCubit(box: box).state, const Locale('en'));
    });

    test('persists a choice', () async {
      when(() => box.get(LocaleCubit.storageKey)).thenReturn(null);
      final cubit = LocaleCubit(box: box);

      await cubit.select(const Locale('id'));

      expect(cubit.state, const Locale('id'));
      verify(() => box.put(LocaleCubit.storageKey, 'id')).called(1);
    });

    test('clearing returns to the device language', () async {
      when(() => box.get(LocaleCubit.storageKey)).thenReturn('en');
      final cubit = LocaleCubit(box: box);

      await cubit.select(null);

      expect(cubit.state, isNull);
      verify(() => box.delete(LocaleCubit.storageKey)).called(1);
    });
  });

  group('currentL10n', () {
    tearDown(() => Intl.defaultLocale = null);

    test('follows the active language', () {
      Intl.defaultLocale = 'en_US';
      expect(currentL10n().localeName, 'en');
      Intl.defaultLocale = 'id_ID';
      expect(currentL10n().localeName, 'id');
    });

    test('never throws for an unsupported locale before the first frame', () {
      Intl.defaultLocale = 'fr_FR';
      expect(currentL10n().localeName, 'id');
    });
  });

  group('translations', () {
    Set<String> keysOf(String path) {
      final data = jsonDecode(File(path).readAsStringSync()) as Map;
      return data.keys.cast<String>().where((k) => !k.startsWith('@')).toSet();
    }

    test('both languages define exactly the same keys', () {
      final en = keysOf('lib/l10n/app_en.arb');
      final id = keysOf('lib/l10n/app_id.arb');

      expect(en.difference(id), isEmpty, reason: 'missing from app_id.arb');
      expect(id.difference(en), isEmpty, reason: 'missing from app_en.arb');
    });

    test('every error key has its own message in both languages', () {
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsId()]) {
        final fallback = l10n.errorMessage('__no_such_key__');
        for (final key in ErrorKeys.all) {
          expect(
            l10n.errorMessage(key),
            isNot(fallback),
            reason: '"$key" falls through to the generic message in '
                '${l10n.localeName}; add a branch to errorMessage',
          );
        }
      }
    });

    test('every prayer and hijri month resolves to a name', () {
      for (final l10n in [AppLocalizationsEn(), AppLocalizationsId()]) {
        for (final prayer in [
          'imsak', 'fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha',
        ]) {
          expect(l10n.prayerName(prayer), isNotEmpty, reason: prayer);
        }
        for (var month = 1; month <= 12; month++) {
          expect(l10n.hijriMonthName(month), isNotEmpty, reason: 'm$month');
        }
      }
    });

    test('keeps the Indonesian names the app already showed', () {
      final id = AppLocalizationsId();
      expect(id.prayerName('fajr'), 'Subuh');
      expect(id.hijriMonthName(9), 'Ramadhan');
      expect(id.hijriDate(1, 10, 1447), '1 Syawal 1447 H');
    });
  });
}
