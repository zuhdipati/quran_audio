import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/quran/data/models/ambient_sound_model.dart';

const String ambientSoundsAsset = 'assets/data/ambient_sounds.json';

abstract class AmbientSoundDataSource {
  Future<List<AmbientSoundModel>> getAmbientSounds();
}

/// Nature recordings bundled in `assets/sounds` (Wikimedia Commons, public
/// domain / CC licensed; attribution lives in the JSON).
class AmbientSoundDataSourceImpl implements AmbientSoundDataSource {
  final AssetJsonLoader loader;

  AmbientSoundDataSourceImpl({required this.loader});

  @override
  Future<List<AmbientSoundModel>> getAmbientSounds() async {
    try {
      final List<dynamic> data = await loader.load(ambientSoundsAsset);
      return data.map((e) => AmbientSoundModel.fromJson(e)).toList();
    } catch (e) {
      throw GeneralException(message: 'Failed to load nature sounds');
    }
  }
}
