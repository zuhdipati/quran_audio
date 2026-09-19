import 'package:hive/hive.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/core/utils/date_time_utils.dart';
import 'package:quran_audio/features/tasbeeh/data/models/dzikir_model.dart';
import 'package:quran_audio/core/error/error_keys.dart';

const String dzikirAsset = 'assets/data/dzikir.json';

abstract class TasbeehLocalDataSource {
  Future<List<DzikirModel>> getDzikirList();

  /// Counts for [day]. Counts saved on any other day read as empty: that is
  /// the midnight reset, with nothing running at midnight.
  Future<Map<String, int>> getCounts(DateTime day);

  /// Saves [count] for [day]; saving on a new day drops the old day's counts.
  Future<void> saveCount(String dzikirId, int count, DateTime day);
}

class TasbeehLocalDataSourceImpl implements TasbeehLocalDataSource {
  final AssetJsonLoader loader;
  final Box box;

  TasbeehLocalDataSourceImpl({required this.loader, required this.box});

  /// `{day: 'yyyy-MM-dd', counts: {dzikirId: count}}`, day in local time.
  static const _countsKey = 'tasbeeh_counts';

  @override
  Future<List<DzikirModel>> getDzikirList() async {
    try {
      final List<dynamic> data = await loader.load(dzikirAsset);
      return data.map((e) => DzikirModel.fromJson(e)).toList();
    } catch (e) {
      throw GeneralException(message: ErrorKeys.loadDzikir);
    }
  }

  @override
  Future<Map<String, int>> getCounts(DateTime day) async {
    final data = box.get(_countsKey);
    // counts saved before they carried a day have no `counts` entry, and
    // are as stale as any other day's
    if (data is! Map ||
        data['day'] != DateTimeUtils.dayKey(day) ||
        data['counts'] is! Map) {
      return {};
    }
    return (data['counts'] as Map).map(
      (key, value) => MapEntry(key.toString(), value as int),
    );
  }

  @override
  Future<void> saveCount(String dzikirId, int count, DateTime day) async {
    final counts = await getCounts(day);
    counts[dzikirId] = count;
    await box.put(_countsKey, {
      'day': DateTimeUtils.dayKey(day),
      'counts': counts,
    });
  }
}
