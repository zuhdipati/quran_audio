import 'package:hive/hive.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';

part 'edition_model.g.dart';

@HiveType(typeId: 0)
class EditionModel {
  @HiveField(0)
  final String identifier;
  @HiveField(1)
  final String language;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String englishName;
  @HiveField(4)
  final String format;
  @HiveField(5)
  final String type;
  @HiveField(6)
  final String? direction;

  const EditionModel({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.type,
    this.direction,
  });

  factory EditionModel.fromJson(Map<String, dynamic> json) => EditionModel(
    identifier: json["identifier"],
    language: json["language"],
    name: json["name"],
    englishName: json["englishName"],
    format: json["format"],
    type: json["type"],
    direction: json["direction"],
  );

  Map<String, dynamic> toJson() => {
    "identifier": identifier,
    "language": language,
    "name": name,
    "englishName": englishName,
    "format": format,
    "type": type,
    "direction": direction,
  };

  EditionEntity toEntity() {
    return EditionEntity(
      identifier: identifier,
      language: language,
      name: name,
      englishName: englishName,
    );
  }
}
