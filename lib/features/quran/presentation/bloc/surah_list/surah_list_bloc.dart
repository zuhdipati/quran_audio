import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_all_surah.dart';

part 'surah_list_event.dart';
part 'surah_list_state.dart';

class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  final GetAllSurah getAllSurah;

  SurahListBloc({required this.getAllSurah}) : super(SurahListInitial()) {
    on<FetchSurahs>(_onFetchSurahs);
    on<SearchSurahs>(_onSearchSurahs);
  }

  Future<void> _onFetchSurahs(
    FetchSurahs event,
    Emitter<SurahListState> emit,
  ) async {
    EditionEntity? currentEdition = event.edition;
    if (state is SurahListLoaded) {
      currentEdition = (state as SurahListLoaded).currentEdition;
    }
    
    emit(SurahListLoading(currentEdition: currentEdition));
    
    final result = await getAllSurah(event.edition.identifier);
    result.fold(
      (failure) => emit(SurahListError(failure.message)),
      (surahs) => emit(SurahListLoaded(
        allSurahs: surahs,
        filteredSurahs: surahs,
        currentEdition: event.edition,
      )),
    );
  }

  void _onSearchSurahs(
    SearchSurahs event,
    Emitter<SurahListState> emit,
  ) {
    if (state is SurahListLoaded) {
      final currentState = state as SurahListLoaded;
      final query = event.query.toLowerCase();
      
      final filtered = currentState.allSurahs.where((surah) {
        return surah.name.toLowerCase().contains(query) ||
            surah.englishName.toLowerCase().contains(query) ||
            surah.englishNameTranslation.toLowerCase().contains(query);
      }).toList();
      
      emit(SurahListLoaded(
        allSurahs: currentState.allSurahs,
        filteredSurahs: filtered,
        currentEdition: currentState.currentEdition,
      ));
    }
  }
}
