import 'package:equatable/equatable.dart';

class EditionEntity extends Equatable {
  final String identifier;
  final String language;
  final String name;
  final String englishName;

  const EditionEntity({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
  });

  @override
  List<Object?> get props => [identifier, language, name, englishName];
}
