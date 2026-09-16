import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_daily_dua.dart';

part 'daily_dua_event.dart';
part 'daily_dua_state.dart';

class DailyDuaBloc extends Bloc<DailyDuaEvent, DailyDuaState> {
  final GetDailyDua getDailyDua;

  DailyDuaBloc({required this.getDailyDua}) : super(DailyDuaInitial()) {
    on<DailyDuaRequested>(_onRequested);
  }

  Future<void> _onRequested(
    DailyDuaRequested event,
    Emitter<DailyDuaState> emit,
  ) async {
    emit(DailyDuaLoading());
    final result = await getDailyDua(event.date);
    result.fold(
      (failure) => emit(DailyDuaError(failure.message)),
      (dua) => emit(DailyDuaLoaded(dua)),
    );
  }
}
