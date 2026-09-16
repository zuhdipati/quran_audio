import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';

class DuaModel {
  final int id;
  final String group;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String? note;
  final String source;
  final bool daily;

  const DuaModel({
    required this.id,
    required this.group,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.note,
    required this.source,
    required this.daily,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
    id: json['id'] ?? 0,
    group: json['group'] ?? '',
    title: json['title'] ?? '',
    arabic: json['arabic'] ?? '',
    latin: json['latin'] ?? '',
    translation: json['translation'] ?? '',
    note: json['note'],
    source: json['source'] ?? '',
    daily: json['daily'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'group': group,
    'title': title,
    'arabic': arabic,
    'latin': latin,
    'translation': translation,
    'note': note,
    'source': source,
    'daily': daily,
  };

  DuaEntity toEntity() => DuaEntity(
    id: id,
    group: group,
    title: title,
    arabic: arabic,
    latin: latin,
    translation: translation,
    note: note,
    source: source,
    isDaily: daily,
  );
}
