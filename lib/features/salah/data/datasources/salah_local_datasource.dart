import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/salah/data/models/salah_guide_model.dart';

const String salahAsset = 'assets/data/salah.json';

abstract class SalahLocalDataSource {
  Future<SalahGuideModel> getGuide();
}

class SalahLocalDataSourceImpl implements SalahLocalDataSource {
  final AssetJsonLoader loader;

  SalahLocalDataSourceImpl({required this.loader});

  @override
  Future<SalahGuideModel> getGuide() async {
    try {
      final Map<String, dynamic> data = await loader.load(salahAsset);
      return SalahGuideModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load salah guide',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'Failed to load salah guide');
    }
  }
}
