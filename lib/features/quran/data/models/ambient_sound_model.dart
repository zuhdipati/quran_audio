import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';

class AmbientSoundModel {
  final String id;
  final String name;
  final String subtitle;
  final String asset;
  final String attribution;
  final String source;

  const AmbientSoundModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.asset,
    required this.attribution,
    required this.source,
  });

  factory AmbientSoundModel.fromJson(Map<String, dynamic> json) =>
      AmbientSoundModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        subtitle: json['subtitle'] ?? '',
        asset: json['asset'] ?? '',
        attribution: json['attribution'] ?? '',
        source: json['source'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'asset': asset,
    'attribution': attribution,
    'source': source,
  };

  AmbientSoundEntity toEntity() => AmbientSoundEntity(
    id: id,
    name: name,
    subtitle: subtitle,
    asset: asset,
    attribution: attribution,
  );
}
