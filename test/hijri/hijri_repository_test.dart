import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/hijri/data/repositories/hijri_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = HijriRepositoryImpl(
    localDataSource: HijriLocalDataSourceImpl(loader: AssetJsonLoader()),
  );

  test('converts a gregorian date to hijri', () {
    final hijri = repository.toHijri(DateTime(2026, 9, 16));
    expect(hijri.formatted, equals('5 Rabiul Akhir 1448 H'));
  });

  test('builds a hijri month with gregorian days and its events', () async {
    final result = await repository.getHijriMonth(1448, 9);
    final month = result.getOrElse(() => throw 'x');

    expect(month.monthName, equals('Ramadhan'));
    expect(month.days.length, inInclusiveRange(29, 30));
    expect(month.days.first.hijri.day, equals(1));
    expect(
      month.days[1].gregorian.difference(month.days[0].gregorian).inDays,
      equals(1),
    );
    expect(month.events.map((e) => e.name), contains("Nuzulul Qur'an"));
  });

  test('returns upcoming events sorted and not in the past', () async {
    final from = DateTime(2026, 9, 16);
    final result = await repository.getUpcomingEvents(from, limit: 4);
    final events = result.getOrElse(() => throw 'x');

    expect(events.length, equals(4));
    for (var i = 0; i < events.length; i++) {
      expect(events[i].gregorian.isBefore(from), isFalse);
      if (i > 0) {
        expect(events[i].gregorian.isBefore(events[i - 1].gregorian), isFalse);
      }
    }
  });
}
