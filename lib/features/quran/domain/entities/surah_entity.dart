import 'package:equatable/equatable.dart';

class SurahEntity extends Equatable {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;

  const SurahEntity({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  @override
  List<Object?> get props => [
    number,
    name,
    englishName,
    englishNameTranslation,
    revelationType,
    numberOfAyahs,
  ];
}
