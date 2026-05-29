import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'surah_list_event.dart';
part 'surah_list_state.dart';

class SurahListBloc extends Bloc<SurahListEvent, SurahListState> {
  SurahListBloc() : super(SurahListInitial()) {
    on<SurahListEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
