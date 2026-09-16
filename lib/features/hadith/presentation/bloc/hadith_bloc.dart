import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/domain/usecases/get_hadith_collection.dart';

part 'hadith_event.dart';
part 'hadith_state.dart';

class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final GetHadithCollection getHadithCollection;

  HadithBloc({required this.getHadithCollection}) : super(HadithInitial()) {
    on<HadithsRequested>(_onRequested);
    on<HadithSearchChanged>(_onSearchChanged);
  }

  Future<void> _onRequested(
    HadithsRequested event,
    Emitter<HadithState> emit,
  ) async {
    emit(HadithLoading());
    final result = await getHadithCollection();
    result.fold(
      (failure) => emit(HadithError(failure.message)),
      (collection) => emit(
        HadithLoaded(collection: collection, filtered: collection.hadiths),
      ),
    );
  }

  void _onSearchChanged(HadithSearchChanged event, Emitter<HadithState> emit) {
    final current = state;
    if (current is! HadithLoaded) return;

    final query = event.query.trim().toLowerCase();
    final filtered = current.collection.hadiths.where((hadith) {
      if (query.isEmpty) return true;
      return hadith.title.toLowerCase().contains(query) ||
          hadith.translation.toLowerCase().contains(query) ||
          hadith.number.toString() == query;
    }).toList();

    emit(HadithLoaded(collection: current.collection, filtered: filtered));
  }
}
