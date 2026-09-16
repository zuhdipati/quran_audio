import 'package:equatable/equatable.dart';

class NiatEntity extends Equatable {
  final String prayer;
  final String title;
  final int rakaat;
  final String arabic;
  final String latin;
  final String translation;

  const NiatEntity({
    required this.prayer,
    required this.title,
    required this.rakaat,
    required this.arabic,
    required this.latin,
    required this.translation,
  });

  @override
  List<Object?> get props => [
    prayer,
    title,
    rakaat,
    arabic,
    latin,
    translation,
  ];
}

class SalahStepEntity extends Equatable {
  final String step;
  final String arabic;
  final String latin;
  final String translation;
  final int repeat;

  const SalahStepEntity({
    required this.step,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.repeat,
  });

  @override
  List<Object?> get props => [step, arabic, latin, translation, repeat];
}

class SalahGuideEntity extends Equatable {
  final List<NiatEntity> niat;
  final List<SalahStepEntity> steps;

  const SalahGuideEntity({required this.niat, required this.steps});

  @override
  List<Object?> get props => [niat, steps];
}
