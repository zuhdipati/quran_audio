import 'package:hive/hive.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';

part 'edition_model.g.dart';

@HiveType(typeId: 0)
class EditionModel {
  @HiveField(0)
  final String? identifier;
  @HiveField(1)
  final String? language;
  @HiveField(2)
  final String? name;
  @HiveField(3)
  final String? englishName;
  @HiveField(4)
  final String? format;
  @HiveField(5)
  final String? type;
  @HiveField(6)
  final String? direction;

  const EditionModel({
    this.identifier,
    this.language,
    this.name,
    this.englishName,
    this.format,
    this.type,
    this.direction,
  });

  factory EditionModel.fromJson(Map<String, dynamic> json) => EditionModel(
    identifier: json["identifier"] ?? '',
    language: json["language"] ?? '',
    name: json["name"] ?? '',
    englishName: json["englishName"] ?? '',
    format: json["format"] ?? '',
    type: json["type"] ?? '',
    direction: json["direction"],
  );

  factory EditionModel.fromIdentifier(String identifier) {
    // extract language from prefix (e.g. "ar" from "ar.alafasy")
    final dotIndex = identifier.indexOf('.');
    final language = dotIndex >= 0 ? identifier.substring(0, dotIndex) : '';

    // generate a readable name from identifier
    final rawName = dotIndex >= 0
        ? identifier.substring(dotIndex + 1)
        : identifier;
    final englishName = rawName.isNotEmpty
        ? rawName[0].toUpperCase() + rawName.substring(1)
        : identifier;

    return EditionModel(
      identifier: identifier,
      language: language,
      name: englishName,
      englishName: englishName,
      format: 'audio',
      type: 'versebyverse',
      direction: null,
    );
  }

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
      identifier: identifier ?? '',
      language: language ?? '',
      name: name ?? '',
      englishName: englishName ?? '',
    );
  }
}
