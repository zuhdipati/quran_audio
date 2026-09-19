import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/error/failure.dart';
import 'package:quran_audio/features/quran/domain/entities/ambient_sound_entity.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_ambient_sounds.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';

import '../../helpers/test_helper.dart';
import 'package:quran_audio/core/error/error_keys.dart';

class MockGetAmbientSounds extends Mock implements GetAmbientSounds {}

class MockGetAmbientSoundFile extends Mock implements GetAmbientSoundFile {}

void main() {
  late MockGetAmbientSounds getSounds;
  late MockGetAmbientSoundFile getFile;
  late List<MockAudioPlayer> players;

  const rain = AmbientSoundEntity(
    id: 'rain',
    name: 'Hujan',
    subtitle: 'Rain',
    file: 'rain.mp3',
    attribution: 'PD',
  );
  const birds = AmbientSoundEntity(
    id: 'birds',
    name: 'Kicau Burung',
    subtitle: 'Birdsong',
    file: 'birds.mp3',
    attribution: 'CC BY-SA',
  );
  const tSounds = [rain, birds];

  setUpAll(() {
    registerFallbackValue(ja.LoopMode.one);
    registerFallbackValue(rain);
  });

  setUp(() {
    getSounds = MockGetAmbientSounds();
    getFile = MockGetAmbientSoundFile();
    players = [];
    when(() => getSounds()).thenAnswer((_) async => const Right(tSounds));
    when(() => getFile(any())).thenAnswer(
      (i) async => Right(
        '/cache/${(i.positionalArguments[0] as AmbientSoundEntity).file}',
      ),
    );
  });

  MockAudioPlayer newPlayer() {
    final player = MockAudioPlayer();
    when(() => player.setFilePath(any())).thenAnswer((_) async => null);
    when(() => player.setLoopMode(any())).thenAnswer((_) async {});
    when(() => player.setVolume(any())).thenAnswer((_) async {});
    when(() => player.play()).thenAnswer((_) async {});
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.dispose()).thenAnswer((_) async {});
    players.add(player);
    return player;
  }

  AmbientBloc build() => AmbientBloc(
    getAmbientSounds: getSounds,
    getAmbientSoundFile: getFile,
    playerFactory: newPlayer,
  );

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  blocTest<AmbientBloc, AmbientState>(
    'plays the downloaded file, looping, per active sound at its own volume',
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      bloc.add(const AmbientSoundToggled('birds'));
      await tick();
      bloc.add(const AmbientVolumeChanged('birds', 0.9));
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, {'rain', 'birds'});
      expect(bloc.state.loadingIds, isEmpty);
      expect(players.length, 2);
      verify(() => players[0].setFilePath('/cache/rain.mp3')).called(1);
      verify(() => players[0].setLoopMode(ja.LoopMode.one)).called(1);
      verify(() => players[0].setVolume(AmbientState.defaultVolume)).called(1);
      verify(() => players[1].setVolume(0.9)).called(1);
    },
  );

  blocTest<AmbientBloc, AmbientState>(
    'shows the sound as loading until its download lands',
    setUp: () {
      final download = Completer<Either<Failure, String>>();
      when(() => getFile(rain)).thenAnswer((_) => download.future);
      addTearDown(() {
        if (!download.isCompleted) download.complete(const Right('/x'));
      });
    },
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      await tick();
    },
    verify: (bloc) {
      expect(bloc.state.isActive('rain'), isTrue);
      expect(bloc.state.isLoading('rain'), isTrue);
      expect(players, isEmpty);
    },
  );

  late Completer<Either<Failure, String>> download;

  blocTest<AmbientBloc, AmbientState>(
    'a sound switched off mid-download never starts playing',
    setUp: () {
      download = Completer();
      when(() => getFile(rain)).thenAnswer((_) => download.future);
    },
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      await tick();
      download.complete(const Right('/cache/rain.mp3'));
      await tick();
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, isEmpty);
      expect(bloc.state.loadingIds, isEmpty);
      expect(players, isEmpty);
    },
  );

  blocTest<AmbientBloc, AmbientState>(
    'a failed download switches the sound back off and says why',
    setUp: () => when(
      () => getFile(rain),
    ).thenAnswer((_) async => Left(Failure(ErrorKeys.noInternet))),
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, isEmpty);
      expect(bloc.state.loadingIds, isEmpty);
      expect(bloc.state.message, ErrorKeys.noInternet);
      expect(players, isEmpty);
    },
  );

  blocTest<AmbientBloc, AmbientState>(
    'toggling off and stopping releases players',
    build: build,
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      bloc.add(const AmbientSoundToggled('birds'));
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
      await tick();
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
    'deactivates a sound whose file fails to play',
    build: () => AmbientBloc(
      getAmbientSounds: getSounds,
      getAmbientSoundFile: getFile,
      playerFactory: () {
        final player = newPlayer();
        when(() => player.setFilePath(any())).thenThrow(Exception('corrupt'));
        return player;
      },
    ),
    act: (bloc) async {
      bloc.add(AmbientSoundsRequested());
      await tick();
      bloc.add(const AmbientSoundToggled('rain'));
    },
    verify: (bloc) {
      expect(bloc.state.activeIds, isEmpty);
      expect(bloc.state.message, ErrorKeys.playSound);
    },
  );
}
