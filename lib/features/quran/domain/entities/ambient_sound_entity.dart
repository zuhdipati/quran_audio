import 'package:equatable/equatable.dart';

class AmbientSoundEntity extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final String asset;
  final String attribution;

  const AmbientSoundEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.asset,
    required this.attribution,
  });

  @override
  List<Object?> get props => [id, name, subtitle, asset, attribution];
}
