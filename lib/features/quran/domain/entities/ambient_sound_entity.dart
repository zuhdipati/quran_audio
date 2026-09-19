import 'package:equatable/equatable.dart';

class AmbientSoundEntity extends Equatable {
  final String id;
  final String name;
  final String subtitle;

  /// Name of the recording in the R2 bucket, e.g. `rain.mp3`.
  final String file;
  final String attribution;

  const AmbientSoundEntity({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.file,
    required this.attribution,
  });

  @override
  List<Object?> get props => [id, name, subtitle, file, attribution];
}
