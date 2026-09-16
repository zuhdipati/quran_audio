import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

class HadithModel {
  final int number;
  final String? title;
  final String arabic;
  final String translation;

  const HadithModel({
    required this.number,
    required this.arabic,
    required this.translation,
    this.title,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String?;
    return HadithModel(
      number: json['number'] ?? 0,
      title: (title == null || title.isEmpty) ? null : title,
      arabic: json['arabic'] ?? '',
      translation: json['translation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    if (title != null) 'title': title,
    'arabic': arabic,
    'translation': translation,
  };

  HadithEntity toEntity({String? source}) => HadithEntity(
    number: number,
    title: title,
    arabic: arabic,
    translation: translation,
    source: source,
  );
}

class HadithCollectionModel {
  final String id;
  final String name;
  final String narrator;
  final int total;
  final int chunkSize;
  final int chunks;
  final bool bundled;

  const HadithCollectionModel({
    required this.id,
    required this.name,
    required this.narrator,
    required this.total,
    required this.chunkSize,
    required this.chunks,
    required this.bundled,
  });

  factory HadithCollectionModel.fromJson(Map<String, dynamic> json) =>
      HadithCollectionModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        narrator: json['narrator'] ?? '',
        total: json['total'] ?? 0,
        chunkSize: json['chunkSize'] ?? 1,
        chunks: json['chunks'] ?? 0,
        bundled: json['bundled'] ?? false,
      );

  HadithCollectionEntity toEntity() => HadithCollectionEntity(
    id: id,
    name: name,
    narrator: narrator,
    total: total,
    chunkSize: chunkSize,
    chunks: chunks,
    bundled: bundled,
  );
}
