import 'package:equatable/equatable.dart';

class DzikirEntity extends Equatable {
  final String id;
  final String arabic;
  final String latin;
  final String translation;
  final int target;
  final String? source;

  const DzikirEntity({
    required this.id,
    required this.arabic,
    required this.latin,
    required this.translation,
    required this.target,
    this.source,
  });

  @override
  List<Object?> get props => [id, arabic, latin, translation, target, source];
}
