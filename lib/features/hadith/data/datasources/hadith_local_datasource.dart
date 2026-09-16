import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';

const String hadithIndexAsset = 'assets/data/hadith_index.json';
const String arbainAsset = 'assets/data/hadiths.json';
const String arbainId = 'arbain-nawawi';

abstract class HadithLocalDataSource {
  /// Narrator catalogue from the bundled manifest.
  Future<List<HadithCollectionModel>> getCollections();

  /// The Arbain collection that ships inside the app.
  Future<List<HadithModel>> getBundledHadiths();

  Future<List<HadithModel>?> readChunk(String collectionId, int chunk);
  Future<void> cacheChunk(
    String collectionId,
    int chunk,
    List<HadithModel> hadiths,
  );
}

class HadithLocalDataSourceImpl implements HadithLocalDataSource {
  final AssetJsonLoader loader;

  /// Optional so tests and the bundled-asset checks can skip Hive entirely.
  final Box? box;

  HadithLocalDataSourceImpl({required this.loader, this.box});

  String _key(String collectionId, int chunk) => 'hadith/$collectionId/$chunk';

  @override
  Future<List<HadithCollectionModel>> getCollections() async {
    try {
      final data = await loader.load(hadithIndexAsset);
      return (data as List)
          .map((e) => HadithCollectionModel.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load hadith index',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'Failed to load hadith collections');
    }
  }

  @override
  Future<List<HadithModel>> getBundledHadiths() async {
    try {
      final Map<String, dynamic> data = await loader.load(arbainAsset);
      return ((data['hadiths'] ?? []) as List)
          .map((e) => HadithModel.fromJson(e))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.e('Failed to load hadiths', error: e, stackTrace: stackTrace);
      throw GeneralException(message: 'Failed to load hadiths');
    }
  }

  @override
  Future<List<HadithModel>?> readChunk(String collectionId, int chunk) async {
    final raw = box?.get(_key(collectionId, chunk));
    if (raw is! String) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => HadithModel.fromJson(e))
          .toList();
    } catch (e) {
      // a corrupt entry should re-fetch rather than break the screen
      AppLogger.e('Discarding corrupt hadith cache entry', error: e);
      await box?.delete(_key(collectionId, chunk));
      return null;
    }
  }

  @override
  Future<void> cacheChunk(
    String collectionId,
    int chunk,
    List<HadithModel> hadiths,
  ) async {
    await box?.put(
      _key(collectionId, chunk),
      jsonEncode(hadiths.map((e) => e.toJson()).toList()),
    );
  }
}
