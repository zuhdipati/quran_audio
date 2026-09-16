import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';

class DzikirModel {
  final String id;
  final String arabic;
  final String latin;
  final String translation;
  final int target;
  final String? source;

  const DzikirModel({
    required this.id,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.target,
    this.source,
  });

  factory DzikirModel.fromJson(Map<String, dynamic> json) => DzikirModel(
    id: json['id'] ?? '',
    arabic: json['arabic'] ?? '',
    latin: json['latin'] ?? '',
    translation: json['translation'] ?? '',
    target: json['target'] ?? 33,
    source: json['source'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'arabic': arabic,
    'latin': latin,
    'translation': translation,
    'target': target,
    'source': source,
  };

  DzikirEntity toEntity() => DzikirEntity(
    id: id,
    arabic: arabic,
    latin: latin,
    translation: translation,
    target: target,
    source: source,
  );
}
