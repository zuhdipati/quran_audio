import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_qibla_direction.dart';
import 'package:quran_audio/features/qibla/domain/usecases/watch_compass_heading.dart';

part 'qibla_event.dart';
part 'qibla_state.dart';

class QiblaBloc extends Bloc<QiblaEvent, QiblaState> {
  final GetQiblaDirection getQiblaDirection;
  final WatchCompassHeading watchCompassHeading;

  StreamSubscription<double?>? _headingSub;

  QiblaBloc({
    required this.getQiblaDirection,
    required this.watchCompassHeading,
  }) : super(const QiblaState()) {
    on<QiblaStarted>(_onStarted);
    on<QiblaHeadingChanged>(_onHeadingChanged);
  }

  void _onStarted(QiblaStarted event, Emitter<QiblaState> emit) {
    final direction = getQiblaDirection(event.location);
    final stream = watchCompassHeading();

    emit(
      QiblaState(
        status: stream == null ? QiblaStatus.noSensor : QiblaStatus.waiting,
        location: event.location,
        qiblaDirection: direction,
      ),
    );

    _headingSub?.cancel();
    _headingSub = stream?.listen(
      (heading) => add(QiblaHeadingChanged(heading)),
      onError: (_) => add(const QiblaHeadingChanged(null)),
    );
  }

  void _onHeadingChanged(QiblaHeadingChanged event, Emitter<QiblaState> emit) {
    if (event.heading == null) {
      emit(state.copyWith(status: QiblaStatus.noSensor));
      return;
    }
    emit(state.copyWith(status: QiblaStatus.tracking, heading: event.heading));
  }

  @override
  Future<void> close() {
    _headingSub?.cancel();
    return super.close();
  }
}
