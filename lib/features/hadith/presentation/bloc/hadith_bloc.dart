import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/usecases/get_hadith_collection.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:rxdart/rxdart.dart';

part 'hadith_event.dart';
part 'hadith_state.dart';

/// Search waits for typing to pause, so a word costs one request, not one
/// per letter.
const Duration hadithSearchDebounce = Duration(milliseconds: 400);

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final GetHadithCollections getHadithCollections;
  final GetHadithPage getHadithPage;
  final SearchHadith searchHadith;

  /// Bumped by every load; a response for an older number is dropped, so a
  /// slow page can never replace a newer one on screen.
  int _request = 0;

  /// Where browsing was when a search started, to return there once the
  /// query is cleared.
  int _browsePage = 1;

  HadithBloc({
    required this.getHadithCollections,
    required this.getHadithPage,
    required this.searchHadith,
  }) : super(const HadithState()) {
    on<HadithsRequested>(_onRequested);
    on<HadithCollectionSelected>(_onCollectionSelected);
    on<HadithPageRequested>(_onPageRequested);
    on<HadithSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounceTime(hadithSearchDebounce).switchMap(mapper),
    );
    on<HadithSearchScopeChanged>(_onSearchScopeChanged);
  }

  Future<void> _onRequested(
    HadithsRequested event,
    Emitter<HadithState> emit,
  ) async {
    emit(state.copyWith(status: HadithStatus.loading));

    final result = await getHadithCollections();
    await result.fold(
      (failure) async => emit(
        state.copyWith(status: HadithStatus.error, message: failure.message),
      ),
      (collections) async {
        if (collections.isEmpty) {
          emit(
            state.copyWith(
              status: HadithStatus.error,
              message: ErrorKeys.noHadithCollections,
            ),
          );
          return;
        }
        emit(
          state.copyWith(collections: collections, selected: collections.first),
        );
        await _load(1, emit, fresh: true);
      },
    );
  }

  Future<void> _onCollectionSelected(
    HadithCollectionSelected event,
    Emitter<HadithState> emit,
  ) async {
    if (event.collection.id == state.selected?.id) return;
    emit(state.copyWith(selected: event.collection));
    _browsePage = 1;
    // results from every collection do not change with the narrator
    if (state.searching && state.searchAll) return;
    await _load(1, emit, fresh: true);
  }

  Future<void> _onPageRequested(
    HadithPageRequested event,
    Emitter<HadithState> emit,
  ) => _load(event.page, emit);

  Future<void> _onSearchChanged(
    HadithSearchChanged event,
    Emitter<HadithState> emit,
  ) async {
    final query = event.query.trim();
    if (query == state.query) return;
    if (!state.searching) _browsePage = state.pageNumber;
    emit(state.copyWith(query: query));
    await _load(query.isEmpty ? _browsePage : 1, emit, fresh: true);
  }

  Future<void> _onSearchScopeChanged(
    HadithSearchScopeChanged event,
    Emitter<HadithState> emit,
  ) async {
    if (event.searchAll == state.searchAll) return;
    emit(state.copyWith(searchAll: event.searchAll));
    if (state.searching) await _load(1, emit, fresh: true);
  }

  /// Shows page [page] of the search results, or of [HadithState.selected]
  /// when there is no query. [fresh] means the listing itself changed, so
  /// the previous page's totals no longer apply.
  Future<void> _load(
    int page,
    Emitter<HadithState> emit, {
    bool fresh = false,
  }) async {
    final collection = state.selected;
    if (collection == null) return;

    final request = ++_request;
    emit(
      state.copyWith(
        status: HadithStatus.loading,
        pageNumber: page,
        clearPage: fresh,
      ),
    );

    final result = state.searching
        ? await searchHadith(
            state.query,
            collection: state.searchAll ? null : collection,
            page: page,
          )
        : await getHadithPage(collection, page);
    if (request != _request) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: HadithStatus.error, message: failure.message),
      ),
      (loaded) =>
          emit(state.copyWith(status: HadithStatus.loaded, page: loaded)),
    );
  }
}
