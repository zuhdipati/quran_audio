import 'package:equatable/equatable.dart';

class SurahEntity extends Equatable {
  final int number;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;

  const SurahEntity({
    required this.number,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  @override
  List<Object?> get props => [
    number,
    englishName,
    englishNameTranslation,
    revelationType,
    numberOfAyahs,
  ];
}
