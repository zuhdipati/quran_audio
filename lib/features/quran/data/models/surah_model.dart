import 'package:quran_audio/features/quran/data/models/ayah_model.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';

class SurahModel {
  int number;
  String name;
  String englishName;
  String englishNameTranslation;
  String revelationType;
  int numberOfAyahs;
  List<AyahModel> ayahs;
  EditionModel edition;

  SurahModel({
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
    number: json["number"],
    name: json["name"],
    englishName: json["englishName"],
    englishNameTranslation: json["englishNameTranslation"],
    revelationType: json["revelationType"],
    numberOfAyahs: json["numberOfAyahs"],
    ayahs: List<AyahModel>.from(
      json["ayahs"].map((x) => AyahModel.fromJson(x)),
    ),
    edition: EditionModel.fromJson(json["edition"]),
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
}
