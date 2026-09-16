import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';

class NiatModel {
  final String prayer;
  final String title;
  final int rakaat;
  final String arabic;
  final String latin;
  final String translation;

  const NiatModel({
    required this.prayer,
    required this.title,
    required this.rakaat,
    required this.arabic,
    required this.latin,
    required this.translation,
  });

  factory NiatModel.fromJson(Map<String, dynamic> json) => NiatModel(
    prayer: json['prayer'] ?? '',
    title: json['title'] ?? '',
    rakaat: json['rakaat'] ?? 0,
    arabic: json['arabic'] ?? '',
    latin: json['latin'] ?? '',
    translation: json['translation'] ?? '',
  );

  NiatEntity toEntity() => NiatEntity(
    prayer: prayer,
    title: title,
    rakaat: rakaat,
    arabic: arabic,
    latin: latin,
    translation: translation,
  );
}

class SalahStepModel {
  final String step;
  final String arabic;
  final String latin;
  final String translation;
  final int repeat;

  const SalahStepModel({
    required this.step,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.repeat,
  });

  factory SalahStepModel.fromJson(Map<String, dynamic> json) => SalahStepModel(
    step: json['step'] ?? '',
    arabic: json['arabic'] ?? '',
    latin: json['latin'] ?? '',
    translation: json['translation'] ?? '',
    repeat: json['repeat'] ?? 1,
  );

  SalahStepEntity toEntity() => SalahStepEntity(
    step: step,
    arabic: arabic,
    latin: latin,
    translation: translation,
    repeat: repeat,
  );
}

class SalahGuideModel {
  final List<NiatModel> niat;
  final List<SalahStepModel> steps;

  const SalahGuideModel({required this.niat, required this.steps});

  factory SalahGuideModel.fromJson(Map<String, dynamic> json) =>
      SalahGuideModel(
        niat: ((json['niat'] ?? []) as List)
            .map((e) => NiatModel.fromJson(e))
            .toList(),
        steps: ((json['steps'] ?? []) as List)
            .map((e) => SalahStepModel.fromJson(e))
            .toList(),
      );

  SalahGuideEntity toEntity() => SalahGuideEntity(
    niat: niat.map((e) => e.toEntity()).toList(),
    steps: steps.map((e) => e.toEntity()).toList(),
  );
}
