import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/prayer_time/domain/entities/location_entity.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_qibla_direction.dart';
import 'package:quran_audio/features/qibla/domain/usecases/watch_compass_heading.dart';
import 'package:quran_audio/features/qibla/presentation/bloc/qibla_bloc.dart';

class MockGetQiblaDirection extends Mock implements GetQiblaDirection {}

class MockWatchCompassHeading extends Mock implements WatchCompassHeading {}

void main() {
  const tLocation = LocationEntity(
    latitude: -6.2,
    longitude: 106.8,
    city: 'Jakarta',
  );
  late MockGetQiblaDirection getDirection;
  late MockWatchCompassHeading watchHeading;

  setUp(() {
    getDirection = MockGetQiblaDirection();
    watchHeading = MockWatchCompassHeading();
    when(() => getDirection(tLocation)).thenReturn(295);
  });

  blocTest<QiblaBloc, QiblaState>(
    'tracks the heading and computes the turn angle',
    setUp: () =>
        when(() => watchHeading()).thenAnswer((_) => Stream.value(270)),
    build: () => QiblaBloc(
      getQiblaDirection: getDirection,
      watchCompassHeading: watchHeading,
    ),
    act: (bloc) => bloc.add(const QiblaStarted(tLocation)),
    verify: (bloc) {
      expect(bloc.state.status, QiblaStatus.tracking);
      expect(bloc.state.turnAngle, 25);
      expect(bloc.state.isFacingQibla, isFalse);
    },
  );

  blocTest<QiblaBloc, QiblaState>(
    'reports a missing sensor',
    setUp: () => when(() => watchHeading()).thenReturn(null),
    build: () => QiblaBloc(
      getQiblaDirection: getDirection,
      watchCompassHeading: watchHeading,
    ),
    act: (bloc) => bloc.add(const QiblaStarted(tLocation)),
    verify: (bloc) {
      expect(bloc.state.status, QiblaStatus.noSensor);
      expect(bloc.state.qiblaDirection, 295);
    },
  );

  test('turn angle takes the short way round', () {
    const state = QiblaState(
      status: QiblaStatus.tracking,
      qiblaDirection: 10,
      heading: 350,
    );
    expect(state.turnAngle, 20);
    const facing = QiblaState(
      status: QiblaStatus.tracking,
      qiblaDirection: 295,
      heading: 298,
    );
    expect(facing.isFacingQibla, isTrue);
  });
}
