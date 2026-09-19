import 'package:hive/hive.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/tasbeeh/data/models/dzikir_model.dart';
import 'package:quran_audio/core/error/error_keys.dart';

const String dzikirAsset = 'assets/data/dzikir.json';

abstract class TasbeehLocalDataSource {
  Future<List<DzikirModel>> getDzikirList();
  Future<Map<String, int>> getCounts();
  Future<void> saveCount(String dzikirId, int count);
}

class TasbeehLocalDataSourceImpl implements TasbeehLocalDataSource {
  final AssetJsonLoader loader;
  final Box box;

  TasbeehLocalDataSourceImpl({required this.loader, required this.box});

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
  Future<Map<String, int>> getCounts() async {
    final data = box.get(_countsKey);
    if (data is! Map) return {};
    return data.map((key, value) => MapEntry(key.toString(), value as int));
  }

  @override
  Future<void> saveCount(String dzikirId, int count) async {
    final counts = await getCounts();
    counts[dzikirId] = count;
    await box.put(_countsKey, counts);
  }
}
