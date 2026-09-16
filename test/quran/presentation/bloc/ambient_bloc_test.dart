import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_ambient_sounds.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';

import '../../helpers/test_helper.dart';

class MockGetAmbientSounds extends Mock implements GetAmbientSounds {}

void main() {
  late MockGetAmbientSounds getSounds;
  late List<MockAudioPlayer> players;

  const tSounds = [
    AmbientSoundEntity(
      id: 'rain',
      name: 'Hujan',
      subtitle: 'Rain',
      asset: 'assets/sounds/rain.mp3',
      attribution: 'PD',
    ),
    AmbientSoundEntity(
      id: 'birds',
      name: 'Kicau Burung',
      subtitle: 'Birdsong',
      asset: 'assets/sounds/birds.mp3',
      attribution: 'CC BY-SA',
    ),
  ];

  setUpAll(() => registerFallbackValue(ja.LoopMode.one));

  setUp(() {
    getSounds = MockGetAmbientSounds();
    players = [];
    when(() => getSounds()).thenAnswer((_) async => const Right(tSounds));
  });

  MockAudioPlayer newPlayer() {
    final player = MockAudioPlayer();
    when(() => player.setAsset(any())).thenAnswer((_) async => null);
    when(() => player.setLoopMode(any())).thenAnswer((_) async {});
    when(() => player.setVolume(any())).thenAnswer((_) async {});
    when(() => player.play()).thenAnswer((_) async {});
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.dispose()).thenAnswer((_) async {});
    players.add(player);
    return player;
  }

  AmbientBloc build() =>
      AmbientBloc(getAmbientSounds: getSounds, playerFactory: newPlayer);

  blocTest<AmbientBloc, AmbientState>(
    'plays a looping asset per active sound at its own volume',
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AmbientSoundToggled('rain'));
      bloc.add(const AmbientSoundToggled('birds'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AmbientVolumeChanged('birds', 0.9));
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, {'rain', 'birds'});
      expect(players.length, 2);
      verify(() => players[0].setAsset('assets/sounds/rain.mp3')).called(1);
      verify(() => players[0].setLoopMode(ja.LoopMode.one)).called(1);
      verify(() => players[0].setVolume(AmbientState.defaultVolume)).called(1);
      verify(() => players[1].setVolume(0.9)).called(1);
    },
  );

  blocTest<AmbientBloc, AmbientState>(
    'toggling off and stopping releases players',
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AmbientSoundToggled('rain'));
      bloc.add(const AmbientSoundToggled('birds'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AmbientSoundToggled('rain'));
      await Future<void>.delayed(Duration.zero);
      bloc.add(AmbientStopped());
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, isEmpty);
      for (final player in players) {
        verify(() => player.dispose()).called(1);
      }
    },
  );

  blocTest<AmbientBloc, AmbientState>(
    'deactivates a sound whose asset fails to load',
    build: () => AmbientBloc(
      getAmbientSounds: getSounds,
      playerFactory: () {
        final player = newPlayer();
        when(() => player.setAsset(any())).thenThrow(Exception('missing'));
        return player;
      },
    ),
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const AmbientSoundToggled('rain'));
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, isEmpty);
      expect(bloc.state.message, 'Unable to play Hujan');
    },
  );
}
