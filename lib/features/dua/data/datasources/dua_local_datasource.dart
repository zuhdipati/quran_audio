import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/dua/data/models/dua_model.dart';

const String duasAsset = 'assets/data/duas.json';

abstract class DuaLocalDataSource {
  Future<List<DuaModel>> getDuas();
}

class DuaLocalDataSourceImpl implements DuaLocalDataSource {
  final AssetJsonLoader loader;

  DuaLocalDataSourceImpl({required this.loader});

  List<DuaModel>? _cache;

  @override
  Future<List<DuaModel>> getDuas() async {
    if (_cache != null) return _cache!;
    try {
      final List<dynamic> data = await loader.load(duasAsset);
      return _cache = data.map((e) => DuaModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load duas', error: e, stackTrace: stackTrace);
      throw GeneralException(message: 'Failed to load duas');
    }
  }
}
