import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'qori_event.dart';
part 'qori_state.dart';

class QoriBloc extends Bloc<QoriEvent, QoriState> {
  QoriBloc() : super(QoriInitial()) {
    on<QoriEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
