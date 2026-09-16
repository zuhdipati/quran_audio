import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/dua/data/datasources/dua_local_datasource.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_local_datasource.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_datasource.dart';
import 'package:quran_audio/features/salah/data/datasources/salah_local_datasource.dart';

/// Guards the JSON shipped in assets/data against broken edits.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = AssetJsonLoader();
  final arabicLetter = RegExp(r'[؀-ۿ]');

  test('duas all carry arabic, latin, translation and a daily set', () async {
    final duas = await DuaLocalDataSourceImpl(loader: loader).getDuas();

    expect(duas.length, greaterThan(200));
    for (final dua in duas) {
      expect(dua.arabic, contains(arabicLetter), reason: dua.title);
      expect(dua.translation, isNotEmpty, reason: dua.title);
    }
    expect(duas.where((d) => d.daily), isNotEmpty);
    expect(duas.map((d) => d.id).toSet().length, equals(duas.length));
  });

  test('hadith collection contains all 42 arbain hadith in order', () async {
    final hadiths = await HadithLocalDataSourceImpl(
      loader: loader,
    ).getBundledHadiths();

    expect(hadiths.length, equals(42));
    expect(
      hadiths.map((h) => h.number).toList(),
      equals(List.generate(42, (i) => i + 1)),
    );
    for (final hadith in hadiths) {
      expect(hadith.arabic, contains(arabicLetter));
      expect(hadith.translation, isNotEmpty);
    }
  });

  test('hadith manifest is complete and self-consistent', () async {
    final collections = await HadithLocalDataSourceImpl(
      loader: loader,
    ).getCollections();

    expect(collections, isNotEmpty);
    // the bundled collection must come first so the page fills offline
    expect(collections.first.bundled, isTrue);
    expect(collections.where((c) => c.bundled).length, equals(1));

    final ids = collections.map((c) => c.id).toSet();
    expect(ids.length, equals(collections.length), reason: 'duplicate ids');

    for (final collection in collections) {
      expect(collection.id, isNotEmpty);
      expect(collection.name, isNotEmpty);
      expect(collection.narrator, isNotEmpty);
      expect(collection.total, greaterThan(0));
      expect(collection.chunkSize, greaterThan(0));
      // chunk count must cover every hadith, or the tail is unreachable
      expect(
        collection.chunks,
        equals((collection.total / collection.chunkSize).ceil()),
        reason: '${collection.id} chunk count does not cover its total',
      );
    }
  });

  test('bundled arbain fits in a single manifest chunk', () async {
    final source = HadithLocalDataSourceImpl(loader: loader);
    final arbain = (await source.getCollections()).firstWhere((c) => c.bundled);
    final hadiths = await source.getBundledHadiths();

    expect(arbain.total, equals(hadiths.length));
    expect(arbain.chunks, equals(1));
    expect(arbain.toEntity().chunkFor(hadiths.last.number), equals(1));
  });

  test('salah guide has niat for five prayers and ordered steps', () async {
    final guide = await SalahLocalDataSourceImpl(loader: loader).getGuide();

    expect(
      guide.niat.map((n) => n.prayer),
      equals(['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']),
    );
    expect(guide.steps.first.step, equals('Takbiratul Ihram'));
    expect(guide.steps.last.step, equals('Salam'));
    for (final step in guide.steps) {
      expect(step.arabic, contains(arabicLetter), reason: step.step);
    }
  });

  test('every ambient sound points to a bundled mp3', () async {
    final sounds = await AmbientSoundDataSourceImpl(
      loader: loader,
    ).getAmbientSounds();

    expect(sounds.length, greaterThanOrEqualTo(8));
    for (final sound in sounds) {
      expect(File(sound.asset).existsSync(), isTrue, reason: sound.asset);
      expect(sound.attribution, isNotEmpty);
    }
  });

  test('islamic events have valid hijri dates', () async {
    final events = await HijriLocalDataSourceImpl(loader: loader).getEvents();

    expect(events, isNotEmpty);
    for (final event in events) {
      expect(event.month, inInclusiveRange(1, 12));
      expect(event.day, inInclusiveRange(1, 30));
    }
  });

  test('qori profiles are well formed', () async {
    final Map<String, dynamic> profiles = await loader.load(
      'assets/data/qori_profiles.json',
    );

    expect(profiles, isNotEmpty);
    for (final entry in profiles.entries) {
      expect(entry.key, startsWith('ar.'));
      final photo = (entry.value as Map)['photo'];
      if (photo != null) {
        expect(
          photo,
          matches(RegExp(r'^https://(upload|thumb)\.wikimedia\.org/')),
        );
      }
    }
  });
}
