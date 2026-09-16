import 'package:equatable/equatable.dart';

class DuaEntity extends Equatable {
  final int id;
  final String group;
  final String title;
  final String arabic;
  final String latin;
  final String translation;
  final String? note;
  final String source;
  final bool isDaily;

  const DuaEntity({
    required this.id,
    required this.group,
    required this.title,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.note,
    required this.source,
    required this.isDaily,
  });

  @override
  List<Object?> get props => [
    id,
    group,
    title,
    arabic,
    latin,
    translation,
    note,
    source,
    isDaily,
  ];
}
