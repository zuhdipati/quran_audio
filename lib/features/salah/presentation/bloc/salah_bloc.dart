import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/salah/domain/entities/salah_guide_entity.dart';
import 'package:quran_audio/features/salah/domain/usecases/get_salah_guide.dart';

part 'salah_event.dart';
part 'salah_state.dart';

class SalahBloc extends Bloc<SalahEvent, SalahState> {
  final GetSalahGuide getSalahGuide;

  SalahBloc({required this.getSalahGuide}) : super(SalahInitial()) {
    on<SalahGuideRequested>(_onRequested);
  }

  Future<void> _onRequested(
    SalahGuideRequested event,
    Emitter<SalahState> emit,
  ) async {
    emit(SalahLoading());
    final result = await getSalahGuide();
    result.fold(
      (failure) => emit(SalahError(failure.message)),
      (guide) => emit(SalahLoaded(guide)),
    );
  }
}
