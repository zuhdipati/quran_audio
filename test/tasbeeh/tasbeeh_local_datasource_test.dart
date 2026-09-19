import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/tasbeeh/data/datasources/tasbeeh_local_datasource.dart';

class MockBox extends Mock implements Box {}

class MockAssetJsonLoader extends Mock implements AssetJsonLoader {}

void main() {
  late Map<dynamic, dynamic> store;
  late TasbeehLocalDataSourceImpl dataSource;

  final today = DateTime(2026, 9, 20, 7, 30);
  final yesterday = DateTime(2026, 9, 19, 23, 59);

  setUp(() {
    // an in-memory box, so what is written is what is read back
    store = {};
    final box = MockBox();
    when(
      () => box.get(any()),
    ).thenAnswer((i) => store[i.positionalArguments[0]]);
    when(() => box.put(any(), any())).thenAnswer((i) async {
      store[i.positionalArguments[0]] = i.positionalArguments[1];
    });
    dataSource = TasbeehLocalDataSourceImpl(
      loader: MockAssetJsonLoader(),
      box: box,
    );
  });

  test('counts saved today come back today, per dzikir', () async {
    await dataSource.saveCount('tasbih', 33, today);
    await dataSource.saveCount('tahmid', 10, today);

    expect(await dataSource.getCounts(today), {'tasbih': 33, 'tahmid': 10});
  });

  test('counts from yesterday read as empty today', () async {
    await dataSource.saveCount('tasbih', 99, yesterday);

    expect(await dataSource.getCounts(today), isEmpty);
    expect(await dataSource.getCounts(yesterday), {'tasbih': 99});
  });

  test('the first save of a new day drops the old day entirely', () async {
    await dataSource.saveCount('tasbih', 99, yesterday);
    await dataSource.saveCount('tahmid', 5, yesterday);

    await dataSource.saveCount('tasbih', 1, today);

    expect(await dataSource.getCounts(today), {'tasbih': 1});
    expect(store['tasbeeh_counts'], {
      'day': '2026-09-20',
      'counts': {'tasbih': 1},
    });
  });

  test('counts saved before they carried a day are treated as stale', () async {
    store['tasbeeh_counts'] = {'tasbih': 32, 'istighfar': 7};

    expect(await dataSource.getCounts(today), isEmpty);
  });
}
