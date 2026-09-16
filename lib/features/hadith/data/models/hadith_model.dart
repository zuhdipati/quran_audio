import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';

class HadithModel {
  final int number;
  final String title;
  final String arabic;
  final String translation;

  const HadithModel({
    required this.number,
    required this.title,
    required this.arabic,
    required this.translation,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) => HadithModel(
    number: json['number'] ?? 0,
    title: json['title'] ?? '',
    arabic: json['arabic'] ?? '',
    translation: json['translation'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'number': number,
    'title': title,
    'arabic': arabic,
    'translation': translation,
  };

  HadithEntity toEntity() => HadithEntity(
    number: number,
    title: title,
    arabic: arabic,
    translation: translation,
  );
}

class HadithCollectionModel {
  final String name;
  final String compiler;
  final List<HadithModel> hadiths;

  const HadithCollectionModel({
    required this.name,
    required this.compiler,
    required this.hadiths,
  });

  factory HadithCollectionModel.fromJson(Map<String, dynamic> json) =>
      HadithCollectionModel(
        name: json['collection'] ?? '',
        compiler: json['narrator'] ?? '',
        hadiths: ((json['hadiths'] ?? []) as List)
            .map((e) => HadithModel.fromJson(e))
            .toList(),
      );

  HadithCollectionEntity toEntity() => HadithCollectionEntity(
    name: name,
    compiler: compiler,
    hadiths: hadiths.map((e) => e.toEntity()).toList(),
  );
}
