import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

class HadithModel {
  final int number;
  final String? title;
  final String arabic;
  final String translation;

  /// Search results name their collection, since they can span several.
  final String? collectionName;
  final String? snippet;

  const HadithModel({
    required this.number,
    required this.arabic,
    required this.translation,
    this.title,
    this.collectionName,
    this.snippet,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String?;
    return HadithModel(
      number: json['number'] ?? 0,
      title: (title == null || title.isEmpty) ? null : title,
      arabic: json['arabic'] ?? '',
      translation: json['translation'] ?? '',
      collectionName: json['collectionName'],
      snippet: json['snippet'],
    );
  }

  HadithEntity toEntity({String? source}) => HadithEntity(
    number: number,
    title: title,
    arabic: arabic,
    translation: translation,
    source: collectionName ?? source,
    snippet: snippet,
  );
}

class HadithCollectionModel {
  final String id;
  final String name;
  final String narrator;
  final int total;

  const HadithCollectionModel({
    required this.id,
    required this.name,
    required this.narrator,
    required this.total,
  });

  factory HadithCollectionModel.fromJson(Map<String, dynamic> json) =>
      HadithCollectionModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        narrator: json['narrator'] ?? '',
        total: json['total'] ?? 0,
      );

  HadithCollectionEntity toEntity() => HadithCollectionEntity(
    id: id,
    name: name,
    narrator: narrator,
    total: total,
  );
}

/// `{data, page, limit, total, totalPages, capped}` from the hadith API.
class HadithPageModel {
  final int page;
  final int totalPages;
  final int total;
  final bool capped;
  final List<HadithModel> hadiths;

  const HadithPageModel({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hadiths,
    this.capped = false,
  });

  factory HadithPageModel.fromJson(Map<String, dynamic> json) =>
      HadithPageModel(
        page: json['page'] ?? 1,
        totalPages: json['totalPages'] ?? 0,
        total: json['total'] ?? 0,
        capped: json['capped'] ?? false,
        hadiths: ((json['data'] ?? []) as List)
            .map((e) => HadithModel.fromJson(e))
            .toList(),
      );

  /// [source] names the collection for pages that do not name it per
  /// hadith, i.e. everything except search.
  HadithPageEntity toEntity({String? source}) => HadithPageEntity(
    page: page,
    totalPages: totalPages,
    total: total,
    capped: capped,
    hadiths: hadiths.map((e) => e.toEntity(source: source)).toList(),
  );
}
