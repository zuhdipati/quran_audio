import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';

abstract class QuranLocalDataSource {
  Future<List<EditionModel>> getAllEdition();
  Future<void> cacheEditions(List<EditionModel> editions);
  Future<List<SurahModel>> getDefaultSurahs();
  Future<void> cacheDefaultSurahs(List<SurahModel> surahs);
}

class QuranLocalDataSourceImpl implements QuranLocalDataSource {
  final Box box;

  QuranLocalDataSourceImpl({required this.box});

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
}
