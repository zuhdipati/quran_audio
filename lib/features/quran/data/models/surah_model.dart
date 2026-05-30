import 'package:quran_audio/features/quran/data/models/ayah_model.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

class SurahModel {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;
  final List<AyahModel> ayahs;
  final EditionModel edition;

  const SurahModel({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
    required this.ayahs,
    required this.edition,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
    number: json["number"] ?? 0,
    name: json["name"] ?? '',
    englishName: json["englishName"] ?? '',
    englishNameTranslation: json["englishNameTranslation"] ?? '',
    revelationType: json["revelationType"] ?? '',
    numberOfAyahs: json["numberOfAyahs"] ?? 0,
    ayahs: json["ayahs"] != null
        ? List<AyahModel>.from(json["ayahs"].map((x) => AyahModel.fromJson(x)))
        : [],
    edition: json["edition"] != null
        ? EditionModel.fromJson(json["edition"])
        : const EditionModel( ),
  );

  Map<String, dynamic> toJson() => {
    "number": number,
    "name": name,
    "englishName": englishName,
    "englishNameTranslation": englishNameTranslation,
    "revelationType": revelationType,
    "numberOfAyahs": numberOfAyahs,
    "ayahs": List<dynamic>.from(ayahs.map((x) => x.toJson())),
    "edition": edition.toJson(),
  };

  SurahEntity toEntity() {
    return SurahEntity(
      number: number,
      name: name,
      englishName: englishName,
      englishNameTranslation: englishNameTranslation,
      revelationType: revelationType,
      numberOfAyahs: numberOfAyahs,
    );
  }
}
