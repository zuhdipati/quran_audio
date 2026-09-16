import 'package:equatable/equatable.dart';

class EditionEntity extends Equatable {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String? photoUrl;

  const EditionEntity({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    this.photoUrl,
  });

  /// Reciter name without the recitation style, e.g. "Abdul Basit Abdus-Samad".
  String get displayName {
    final index = englishName.indexOf('(');
    return index > 0 ? englishName.substring(0, index).trim() : englishName;
  }

  /// Recitation style from the trailing parentheses, e.g. "Mujawwad".
  String? get style {
    final match = RegExp(r'\(([^)]*)\)\s*$').firstMatch(englishName);
    return match?.group(1);
  }

  @override
  List<Object?> get props => [
    identifier,
    language,
    name,
    englishName,
    photoUrl,
  ];
}
