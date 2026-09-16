import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';

const String hadithsAsset = 'assets/data/hadiths.json';

abstract class HadithLocalDataSource {
  Future<HadithCollectionModel> getCollection();
}

class HadithLocalDataSourceImpl implements HadithLocalDataSource {
  final AssetJsonLoader loader;

  HadithLocalDataSourceImpl({required this.loader});

  @override
  Future<HadithCollectionModel> getCollection() async {
    try {
      final Map<String, dynamic> data = await loader.load(hadithsAsset);
      return HadithCollectionModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load hadiths', error: e, stackTrace: stackTrace);
      throw GeneralException(message: 'Failed to load hadiths');
    }
  }
}
