import 'package:equatable/equatable.dart';

class HadithEntity extends Equatable {
  final int number;

  /// Only the bundled Arbain collection carries titles; the hosted
  /// collections have none, so lists fall back to a translation excerpt.
  final String? title;

  final String arabic;
  final String translation;

  /// Display name of the collection this came from, so the detail screen
  /// can attribute it without the route carrying extra baggage.
  final String? source;

  const HadithEntity({
    required this.number,
    required this.arabic,
    required this.translation,
    this.title,
    this.source,
  });

  @override
  List<Object?> get props => [number, title, arabic, translation, source];
}

/// A catalogue entry for the narrator picker. Cheap enough to ship in the
/// app bundle, so the picker renders offline before anything is fetched.
class HadithCollectionEntity extends Equatable {
  final String id;
  final String name;
  final String narrator;
  final int total;
  final int chunkSize;
  final int chunks;

  /// True when the hadiths ship inside the app rather than on R2.
  final bool bundled;

  const HadithCollectionEntity({
    required this.id,
    required this.name,
    required this.narrator,
    required this.total,
    required this.chunkSize,
    required this.chunks,
    this.bundled = false,
  });

  /// 1-based chunk holding [number], matching the build script's layout.
  int chunkFor(int number) => ((number - 1) ~/ chunkSize) + 1;

  @override
  List<Object?> get props => [id, name, narrator, total, chunkSize, chunks, bundled];
}

/// One fetched page of a collection.
class HadithPageEntity extends Equatable {
  final String collectionId;
  final int chunk;
  final List<HadithEntity> hadiths;

  const HadithPageEntity({
    required this.collectionId,
    required this.chunk,
    required this.hadiths,
  });

  @override
  List<Object?> get props => [collectionId, chunk, hadiths];
}
