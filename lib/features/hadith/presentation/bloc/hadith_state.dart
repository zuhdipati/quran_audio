part of 'hadith_bloc.dart';

enum HadithStatus { initial, loading, loaded, error }

class HadithState extends Equatable {
  final HadithStatus status;

  /// Every collection the API serves, for the narrator picker.
  final List<HadithCollectionEntity> collections;

  final HadithCollectionEntity? selected;

  /// The search text; empty means browsing [selected].
  final String query;

  /// Search every collection instead of only [selected].
  final bool searchAll;

  /// The page being shown or loaded, 1-based; what a retry asks for again.
  final int pageNumber;

  /// The last page that arrived. Kept while the next one loads, so the
  /// pager holds its place.
  final HadithPageEntity? page;

  final String? message;

  const HadithState({
    this.status = HadithStatus.initial,
    this.collections = const [],
    this.selected,
    this.query = '',
    this.searchAll = false,
    this.pageNumber = 1,
    this.page,
    this.message,
  });

  bool get searching => query.isNotEmpty;

  HadithState copyWith({
    HadithStatus? status,
    List<HadithCollectionEntity>? collections,
    HadithCollectionEntity? selected,
    String? query,
    bool? searchAll,
    int? pageNumber,
    HadithPageEntity? page,
    bool clearPage = false,
    String? message,
  }) => HadithState(
    status: status ?? this.status,
    collections: collections ?? this.collections,
    selected: selected ?? this.selected,
    query: query ?? this.query,
    searchAll: searchAll ?? this.searchAll,
    pageNumber: pageNumber ?? this.pageNumber,
    page: clearPage ? null : page ?? this.page,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    collections,
    selected,
    query,
    searchAll,
    pageNumber,
    page,
    message,
  ];
}
