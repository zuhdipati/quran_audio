part of 'hadith_bloc.dart';

enum HadithStatus { initial, loading, loaded, error }

class HadithState extends Equatable {
  final HadithStatus status;

  /// Every collection the app knows about, from the bundled manifest.
  final List<HadithCollectionEntity> collections;

  final HadithCollectionEntity? selected;

  /// Hadiths fetched so far for [selected], in order.
  final List<HadithEntity> hadiths;

  /// Highest chunk already loaded; 0 means nothing yet.
  final int loadedChunks;

  final bool loadingMore;
  final String query;
  final String? message;

  const HadithState({
    this.status = HadithStatus.initial,
    this.collections = const [],
    this.selected,
    this.hadiths = const [],
    this.loadedChunks = 0,
    this.loadingMore = false,
    this.query = '',
    this.message,
  });

  bool get hasMore {
    final collection = selected;
    return collection != null && loadedChunks < collection.chunks;
  }

  /// Search only covers what has been fetched — the corpus is far too large
  /// to filter client-side, so the UI says so rather than implying
  /// otherwise.
  List<HadithEntity> get visible {
    if (query.isEmpty) return hadiths;
    final needle = query.toLowerCase();
    return hadiths.where((hadith) {
      return (hadith.title?.toLowerCase().contains(needle) ?? false) ||
          hadith.translation.toLowerCase().contains(needle) ||
          hadith.number.toString() == needle;
    }).toList();
  }

  HadithState copyWith({
    HadithStatus? status,
    List<HadithCollectionEntity>? collections,
    HadithCollectionEntity? selected,
    List<HadithEntity>? hadiths,
    int? loadedChunks,
    bool? loadingMore,
    String? query,
    String? message,
  }) => HadithState(
    status: status ?? this.status,
    collections: collections ?? this.collections,
    selected: selected ?? this.selected,
    hadiths: hadiths ?? this.hadiths,
    loadedChunks: loadedChunks ?? this.loadedChunks,
    loadingMore: loadingMore ?? this.loadingMore,
    query: query ?? this.query,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    collections,
    selected,
    hadiths,
    loadedChunks,
    loadingMore,
    query,
    message,
  ];
}
