import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_duas.dart';

part 'dua_event.dart';
part 'dua_state.dart';

class DuaBloc extends Bloc<DuaEvent, DuaState> {
  final GetDuas getDuas;

  DuaBloc({required this.getDuas}) : super(const DuaState()) {
    on<DuasRequested>(_onRequested);
    on<DuaSearchChanged>(_onSearchChanged);
    on<DuaGroupSelected>(_onGroupSelected);
  }

  Future<void> _onRequested(DuasRequested event, Emitter<DuaState> emit) async {
    emit(state.copyWith(status: DuaStatus.loading));
    final result = await getDuas();
    result.fold(
      (failure) => emit(
        state.copyWith(status: DuaStatus.error, message: failure.message),
      ),
      (duas) {
        final groups = <String>[];
        for (final dua in duas) {
          if (!groups.contains(dua.group)) groups.add(dua.group);
        }
        emit(
          DuaState(
            status: DuaStatus.loaded,
            allDuas: duas,
            filteredDuas: duas,
            groups: groups,
          ),
        );
      },
    );
  }

  void _onSearchChanged(DuaSearchChanged event, Emitter<DuaState> emit) {
    emit(_filtered(query: event.query, group: state.selectedGroup));
  }

  void _onGroupSelected(DuaGroupSelected event, Emitter<DuaState> emit) {
    emit(_filtered(query: state.query, group: event.group));
  }

  DuaState _filtered({required String query, required String? group}) {
    final normalized = query.trim().toLowerCase();
    final filtered = state.allDuas.where((dua) {
      final matchesGroup = group == null || dua.group == group;
      if (!matchesGroup) return false;
      if (normalized.isEmpty) return true;
      return dua.title.toLowerCase().contains(normalized) ||
          dua.group.toLowerCase().contains(normalized) ||
          dua.translation.toLowerCase().contains(normalized) ||
          dua.latin.toLowerCase().contains(normalized);
    }).toList();

    return DuaState(
      status: state.status,
      allDuas: state.allDuas,
      filteredDuas: filtered,
      groups: state.groups,
      selectedGroup: group,
      query: query,
    );
  }
}
