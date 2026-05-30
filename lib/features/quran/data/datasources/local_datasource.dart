import 'package:hive/hive.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';

abstract class QuranLocalDataSource {
  Future<List<EditionModel>> getAllEdition();
  Future<void> cacheEditions(List<EditionModel> editions);
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
}
