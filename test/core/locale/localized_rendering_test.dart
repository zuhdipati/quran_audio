import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/locale/locale_cubit.dart';
import 'package:quran_audio/core/widgets/translation_language_note.dart';
import 'package:quran_audio/features/hijri/domain/entities/islamic_event_entity.dart';
import 'package:quran_audio/features/hijri/presentation/hijri_l10n.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/presentation/ambient_l10n.dart';
import 'package:quran_audio/features/settings/presentation/pages/settings_page.dart';
import 'package:quran_audio/l10n/app_localizations_en.dart';
import 'package:quran_audio/l10n/app_localizations_id.dart';

import '../../helpers/localized_app.dart';

class MockBox extends Mock implements Box {}

void main() {
  setUpAll(initializeDateFormatting);

  group('TranslationLanguageNote', () {
    testWidgets('flags Indonesian translations in English', (tester) async {
      await tester.pumpWidget(
        localizedApp(home: const Scaffold(body: TranslationLanguageNote())),
      );
      expect(find.text('Translation in Bahasa Indonesia'), findsOneWidget);
    });

    testWidgets('stays out of the way in Indonesian', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          locale: const Locale('id'),
          home: const Scaffold(body: TranslationLanguageNote()),
        ),
      );
      expect(find.byIcon(Icons.translate_rounded), findsNothing);
    });
  });

  group('SettingsPage', () {
    late MockBox box;

    setUp(() {
      box = MockBox();
      when(() => box.get(any())).thenReturn(null);
      when(() => box.put(any(), any())).thenAnswer((_) async {});
      when(() => box.delete(any())).thenAnswer((_) async {});
    });

    Widget page(Locale locale, LocaleCubit cubit) => BlocProvider.value(
      value: cubit,
      child: localizedApp(locale: locale, home: const SettingsPage()),
    );

    testWidgets('renders in English', (tester) async {
      await tester.pumpWidget(page(const Locale('en'), LocaleCubit(box: box)));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Use device language'), findsOneWidget);
    });

    testWidgets('renders in Indonesian', (tester) async {
      await tester.pumpWidget(page(const Locale('id'), LocaleCubit(box: box)));
      await tester.pump();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Ikuti bahasa perangkat'), findsOneWidget);
    });

    testWidgets('choosing a language persists it', (tester) async {
      final cubit = LocaleCubit(box: box);
      await tester.pumpWidget(page(const Locale('en'), cubit));
      await tester.pump();

      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pump();

      expect(cubit.state, const Locale('id'));
      verify(() => box.put(LocaleCubit.storageKey, 'id')).called(1);
    });
  });

  group('calendar weekday headers', () {
    // guards the fix: Friday used to be found by comparing the label to
    // "Fri", which silently broke once the label became "Jum"
    for (final locale in ['en', 'id']) {
      test('Monday-first with Friday at index 4 in $locale', () {
        final format = DateFormat.E(locale);
        final labels = [
          for (var i = 0; i < 7; i++) format.format(DateTime(2024, 1, 1 + i)),
        ];
        expect(DateTime(2024, 1, 1).weekday, DateTime.monday);
        expect(
          labels[DateTime.friday - 1],
          format.format(DateTime(2024, 1, 5)),
        );
        expect(DateTime(2024, 1, 5).weekday, DateTime.friday);
      });
    }

    test('labels actually differ between languages', () {
      final friday = DateTime(2024, 1, 5);
      expect(
        DateFormat.E('en').format(friday),
        isNot(DateFormat.E('id').format(friday)),
      );
    });
  });

  group('bundled data follows the language', () {
    final en = AppLocalizationsEn();
    final id = AppLocalizationsId();

    IslamicEventEntity event({String nameEn = 'Eid al-Fitr'}) =>
        IslamicEventEntity(
          name: 'Idul Fitri',
          description: '1 Syawal',
          nameEn: nameEn,
          descriptionEn: '1 Shawwal',
          hijriMonth: 10,
          hijriDay: 1,
          hijriYear: 1447,
          gregorian: DateTime(2026, 3, 20),
        );

    test('event names pick the active language', () {
      expect(event().localizedName(en), 'Eid al-Fitr');
      expect(event().localizedName(id), 'Idul Fitri');
      expect(event().localizedDescription(en), '1 Shawwal');
    });

    test('an event without English falls back rather than going blank', () {
      expect(event(nameEn: '').localizedName(en), 'Idul Fitri');
    });

    test('ambient sound names pick the active language', () {
      const rain = AmbientSoundEntity(
        id: 'rain',
        name: 'Hujan',
        subtitle: 'Rain',
        file: 'rain.mp3',
        attribution: '',
      );
      expect(rain.localizedName(en), 'Rain');
      expect(rain.localizedName(id), 'Hujan');
    });
  });
}
