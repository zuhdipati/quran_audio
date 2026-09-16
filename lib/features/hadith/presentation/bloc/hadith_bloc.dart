import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/usecases/get_hadith_collection.dart';

part 'hadith_event.dart';
part 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final GetHadithCollections getHadithCollections;
  final GetHadithPage getHadithPage;

  HadithBloc({
    required this.getHadithCollections,
    required this.getHadithPage,
  }) : super(const HadithState()) {
    on<HadithsRequested>(_onRequested);
    on<HadithCollectionSelected>(_onCollectionSelected);
    on<HadithNextPageRequested>(_onNextPage);
    on<HadithSearchChanged>(_onSearchChanged);
  }

  Future<void> _onRequested(
    HadithsRequested event,
    Emitter<HadithState> emit,
  ) async {
    emit(state.copyWith(status: HadithStatus.loading));

    final result = await getHadithCollections();
    await result.fold(
      (failure) async =>
          emit(state.copyWith(status: HadithStatus.error, message: failure.message)),
      (collections) async {
        if (collections.isEmpty) {
          emit(
            state.copyWith(
              status: HadithStatus.error,
              message: 'No hadith collections available',
            ),
          );
          return;
        }
        emit(state.copyWith(collections: collections));
        // the bundled collection opens first so the screen fills offline
        await _open(collections.first, emit);
      },
    );
  }

  Future<void> _onCollectionSelected(
    HadithCollectionSelected event,
    Emitter<HadithState> emit,
  ) async {
    if (event.collection.id == state.selected?.id) return;
    await _open(event.collection, emit);
  }

  Future<void> _open(
    HadithCollectionEntity collection,
    Emitter<HadithState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HadithStatus.loading,
        selected: collection,
        hadiths: const [],
        loadedChunks: 0,
        query: '',
      ),
    );

    final result = await getHadithPage(collection, 1);
    result.fold(
      (failure) => emit(
        state.copyWith(status: HadithStatus.error, message: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          status: HadithStatus.loaded,
          hadiths: page.hadiths,
          loadedChunks: 1,
        ),
      ),
    );
  }

  Future<void> _onNextPage(
    HadithNextPageRequested event,
    Emitter<HadithState> emit,
  ) async {
    final collection = state.selected;
    if (collection == null || state.loadingMore || !state.hasMore) return;

    emit(state.copyWith(loadingMore: true));

    final next = state.loadedChunks + 1;
    final result = await getHadithPage(collection, next);
    result.fold(
      (failure) => emit(
        state.copyWith(loadingMore: false, message: failure.message),
      ),
      (page) => emit(
        state.copyWith(
          loadingMore: false,
          hadiths: [...state.hadiths, ...page.hadiths],
          loadedChunks: next,
        ),
      ),
    );
  }

  void _onSearchChanged(HadithSearchChanged event, Emitter<HadithState> emit) {
    emit(state.copyWith(query: event.query.trim()));
  }
}
