import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_qori.dart';

part 'edition_event.dart';
part 'edition_state.dart';

class EditionBloc extends Bloc<EditionEvent, EditionState> {
  final GetAllEdition getAllEdition;

  EditionBloc({required this.getAllEdition}) : super(EditionInitial()) {
    on<GetEditions>(_onFetchEditions);
    on<SearchEditions>(_onSearchEditions);
  }

  Future<void> _onFetchEditions(
    GetEditions event,
    Emitter<EditionState> emit,
  ) async {
    emit(EditionLoading());
    final result = await getAllEdition();
    result.fold(
      (failure) => emit(EditionError(failure.message)),
      (editions) => emit(
        EditionLoaded(allEditions: editions, filteredEditions: editions),
      ),
    );
  }

  void _onSearchEditions(SearchEditions event, Emitter<EditionState> emit) {
    if (state is EditionLoaded) {
      final currentState = state as EditionLoaded;
      final query = event.query.toLowerCase();

      final filtered = currentState.allEditions.where((edition) {
        return edition.name.toLowerCase().contains(query) ||
            edition.englishName.toLowerCase().contains(query) ||
            edition.identifier.toLowerCase().contains(query);
      }).toList();

      emit(
        EditionLoaded(
          allEditions: currentState.allEditions,
          filteredEditions: filtered,
        ),
      );
    }
  }
}
