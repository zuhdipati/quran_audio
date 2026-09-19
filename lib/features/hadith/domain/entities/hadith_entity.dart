import 'package:equatable/equatable.dart';

class HadithEntity extends Equatable {
  final int number;

  /// Only Arbain carries titles; the other collections have none, so lists
  /// fall back to a translation excerpt.
  final String? title;

  final String arabic;
  final String translation;

  /// Display name of the collection this came from, so the detail screen
  /// can attribute it without the route carrying extra baggage.
  final String? source;

  /// Search results only: the translation around the match, each matched
  /// word wrapped in `<mark>` and `</mark>`.
  final String? snippet;

  const HadithEntity({
    required this.number,
    required this.arabic,
    required this.translation,
    this.title,
    this.source,
    this.snippet,
  });

  @override
  List<Object?> get props => [
    number,
    title,
    arabic,
    translation,
    source,
    snippet,
  ];
}

/// A catalogue entry for the narrator picker.
class HadithCollectionEntity extends Equatable {
  final String id;
  final String name;
  final String narrator;
  final int total;

  const HadithCollectionEntity({
    required this.id,
    required this.name,
    required this.narrator,
    required this.total,
  });

  @override
  List<Object?> get props => [id, name, narrator, total];
}

/// One page of a collection, or of search results.
class HadithPageEntity extends Equatable {
  /// 1-based.
  final int page;
  final int totalPages;

  /// Hadith across every page. For search this stops at the server's cap;
  /// see [capped].
  final int total;

  /// The search matched more than [total], and only the first [total] can
  /// be paged through.
  final bool capped;

  final List<HadithEntity> hadiths;

  const HadithPageEntity({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hadiths,
    this.capped = false,
  });

  @override
  List<Object?> get props => [page, totalPages, total, capped, hadiths];
}
