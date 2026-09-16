import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/data/models/qori_profile_model.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';

abstract class QuranLocalDataSource {
  Future<List<EditionModel>> getAllEdition();
  Future<void> cacheEditions(List<EditionModel> editions);
  Future<List<SurahModel>> getDefaultSurahs();
  Future<void> cacheDefaultSurahs(List<SurahModel> surahs);
  Future<Map<String, QoriProfileModel>> getQoriProfiles();
}

const String qoriProfilesAsset = 'assets/data/qori_profiles.json';

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final Box box;
  final AssetJsonLoader loader;

  QuranLocalDataSourceImpl({required this.box, AssetJsonLoader? loader})
    : loader = loader ?? AssetJsonLoader();

  Map<String, QoriProfileModel>? _profiles;

  @override
  Future<List<EditionModel>> getAllEdition() async {
    final editions = box.get('all_edition');
    if (editions == null) return [];
    return List<EditionModel>.from(editions);
  }

  @override
  Future<void> cacheEditions(List<EditionModel> editions) async {
    await box.put('all_edition', editions);
  }

  @override
  Future<List<SurahModel>> getDefaultSurahs() async {
    final String? jsonString = box.get('default_surahs');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => SurahModel.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheDefaultSurahs(List<SurahModel> surahs) async {
    final lightweightSurahs = surahs.map((surah) {
      final json = surah.toJson();
      json['ayahs'] = [];
      return json;
    }).toList();

    final jsonString = jsonEncode(lightweightSurahs);
    await box.put('default_surahs', jsonString);
  }

  @override
  Future<Map<String, QoriProfileModel>> getQoriProfiles() async {
    if (_profiles != null) return _profiles!;
    try {
      final Map<String, dynamic> data = await loader.load(qoriProfilesAsset);
      return _profiles = data.map(
        (identifier, json) =>
            MapEntry(identifier, QoriProfileModel.fromJson(json)),
      );
    } catch (e) {
      // profiles only add photos and nicer names
      AppLogger.w('Failed to load qori profiles', error: e);
      return {};
    }
  }
}
