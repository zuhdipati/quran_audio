import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/quran/data/models/ambient_sound_model.dart';
import 'package:quran_audio/core/error/error_keys.dart';

const String ambientSoundsAsset = 'assets/data/ambient_sounds.json';

abstract class AmbientSoundDataSource {
  Future<List<AmbientSoundModel>> getAmbientSounds();
}

/// The list of nature recordings, bundled so the mixer opens offline
/// (Wikimedia Commons, public domain / CC licensed; attribution lives in the
/// JSON). The audio itself comes from R2 via `AmbientSoundFileDataSource`.
class AmbientSoundDataSourceImpl implements AmbientSoundDataSource {
  final AssetJsonLoader loader;

  AmbientSoundDataSourceImpl({required this.loader});

  @override
  Future<List<AmbientSoundModel>> getAmbientSounds() async {
    try {
      final List<dynamic> data = await loader.load(ambientSoundsAsset);
      return data.map((e) => AmbientSoundModel.fromJson(e)).toList();
    } catch (e) {
      throw GeneralException(message: ErrorKeys.loadNatureSounds);
    }
  }
}
