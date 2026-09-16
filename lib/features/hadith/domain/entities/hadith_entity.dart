import 'package:equatable/equatable.dart';

class HadithEntity extends Equatable {
  final int number;
  final String title;
  final String arabic;
  final String translation;

  const HadithEntity({
    required this.number,
    required this.title,
    required this.arabic,
    required this.translation,
  });

  @override
  List<Object?> get props => [number, title, arabic, translation];
}

class HadithCollectionEntity extends Equatable {
  final String name;
  final String compiler;
  final List<HadithEntity> hadiths;

  const HadithCollectionEntity({
    required this.name,
    required this.compiler,
    required this.hadiths,
  });

  @override
  List<Object?> get props => [name, compiler, hadiths];
}
