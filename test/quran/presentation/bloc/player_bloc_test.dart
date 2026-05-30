import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';

import '../../helpers/test_helper.dart';

class FakeUri extends Fake implements Uri {}
class FakeAudioSource extends Fake implements ja.AudioSource {}

void main() {
  late PlayerBloc playerBloc;
  late MockAudioPlayer mockAudioPlayer;

  const tSurah1 = SurahEntity(
    number: 1,
    name: 'Al-Fatihah',
    englishName: 'Al-Fatihah',
    englishNameTranslation: 'The Opening',
    revelationType: 'Meccan',
    numberOfAyahs: 7,
  );
  
  const tSurah2 = SurahEntity(
    number: 2,
    name: 'Al-Baqarah',
    englishName: 'Al-Baqarah',
    englishNameTranslation: 'The Cow',
    revelationType: 'Medinan',
    numberOfAyahs: 286,
  );

  const tSurahList = [tSurah1, tSurah2];
  const tEdition = 'ar.alafasy';

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeAudioSource());
  });

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();

    // setup stream stubs since bloc listens to them in constructor
    when(() => mockAudioPlayer.positionStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAudioPlayer.durationStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAudioPlayer.playerStateStream).thenAnswer((_) => const Stream.empty());
    when(() => mockAudioPlayer.dispose()).thenAnswer((_) async {});
    when(() => mockAudioPlayer.setAudioSource(any())).thenAnswer((_) async => null);
    when(() => mockAudioPlayer.play()).thenAnswer((_) async {});
    when(() => mockAudioPlayer.pause()).thenAnswer((_) async {});
    when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
    when(() => mockAudioPlayer.seek(any())).thenAnswer((_) async {});

    playerBloc = PlayerBloc(audioPlayer: mockAudioPlayer);
  });

  tearDown(() {
    playerBloc.close();
  });

  test('initial state should be PlayerState with initial status', () {
    expect(playerBloc.state.status, equals(PlayerStatus.initial));
  });

  test('initial state should be correct with default audio player', () {
    final bloc = PlayerBloc();
    expect(bloc.state.status, equals(PlayerStatus.initial));
    bloc.close();
  });

  blocTest<PlayerBloc, PlayerState>(
    'should update position when stream emits',
    build: () {
      final mock = MockAudioPlayer();
      when(() => mock.positionStream).thenAnswer((_) => Stream.value(const Duration(seconds: 1)));
      when(() => mock.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.dispose()).thenAnswer((_) async {});
      return PlayerBloc(audioPlayer: mock);
    },
    expect: () => [
      const PlayerState(position: Duration(seconds: 1)),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should update duration when stream emits',
    build: () {
      final mock = MockAudioPlayer();
      when(() => mock.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.durationStream).thenAnswer((_) => Stream.value(const Duration(seconds: 2)));
      when(() => mock.playerStateStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.dispose()).thenAnswer((_) async {});
      return PlayerBloc(audioPlayer: mock);
    },
    expect: () => [
      const PlayerState(duration: Duration(seconds: 2)),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit AudioCompleted when playerStateStream emits completed',
    build: () {
      final mock = MockAudioPlayer();
      when(() => mock.positionStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.durationStream).thenAnswer((_) => const Stream.empty());
      when(() => mock.playerStateStream).thenAnswer(
          (_) => Stream.value(ja.PlayerState(false, ja.ProcessingState.completed)));
      when(() => mock.dispose()).thenAnswer((_) async {});
      return PlayerBloc(audioPlayer: mock);
    },
    expect: () => [
      const PlayerState(status: PlayerStatus.completed, position: Duration.zero),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit [loading, paused, playing] when LoadSurah is added successfully',
    build: () => playerBloc,
    act: (bloc) => bloc.add(const LoadSurah(tSurah1, editionIdentifier: tEdition, surahList: tSurahList)),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.loading,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
      ),
      const PlayerState(
        status: PlayerStatus.paused,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
      ),
      const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
      ),
    ],
    verify: (bloc) {
      verify(() => mockAudioPlayer.setAudioSource(any())).called(1);
      verify(() => mockAudioPlayer.play()).called(1);
    },
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit [loading, error] when LoadSurah fails',
    build: () {
      when(() => mockAudioPlayer.setAudioSource(any())).thenThrow(Exception('Failed'));
      return playerBloc;
    },
    act: (bloc) => bloc.add(const LoadSurah(tSurah1, editionIdentifier: tEdition, surahList: tSurahList)),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.loading,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
      ),
      const PlayerState(
        status: PlayerStatus.error,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
        errorMessage: 'Failed to load audio',
      ),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit [playing] state when PlayAudio is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(PlayAudio()),
    expect: () => [
      isA<PlayerState>().having((s) => s.status, 'status', PlayerStatus.playing),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit [paused] state when PauseAudio is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(PauseAudio()),
    expect: () => [
      isA<PlayerState>().having((s) => s.status, 'status', PlayerStatus.paused),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit [playing] state when ResumeAudio is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(ResumeAudio()),
    expect: () => [
      isA<PlayerState>().having((s) => s.status, 'status', PlayerStatus.playing),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit states for next surah when NextSurah is added and there is a next surah',
    build: () => playerBloc,
    seed: () => const PlayerState(
      currentSurah: tSurah1,
      surahList: tSurahList,
      editionIdentifier: tEdition,
    ),
    act: (bloc) => bloc.add(NextSurah()),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.loading,
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.paused,
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should emit states for prev surah when PreviousSurah is added and there is a prev surah',
    build: () => playerBloc,
    seed: () => const PlayerState(
      currentSurah: tSurah2,
      surahList: tSurahList,
      editionIdentifier: tEdition,
    ),
    act: (bloc) => bloc.add(PreviousSurah()),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.loading,
        currentSurah: tSurah1,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.paused,
        currentSurah: tSurah1,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah1,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should call seek on audio player when SeekAudio is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(const SeekAudio(Duration(seconds: 10))),
    verify: (bloc) {
      verify(() => mockAudioPlayer.seek(const Duration(seconds: 10))).called(1);
    },
  );

  blocTest<PlayerBloc, PlayerState>(
    'should update position when UpdatePosition is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(const UpdatePosition(Duration(seconds: 5))),
    expect: () => [
      const PlayerState(position: Duration(seconds: 5)),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should update duration when UpdateDuration is added',
    build: () => playerBloc,
    act: (bloc) => bloc.add(const UpdateDuration(Duration(minutes: 1))),
    expect: () => [
      const PlayerState(duration: Duration(minutes: 1)),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should set status to completed and position to duration when AudioCompleted is added',
    build: () => playerBloc,
    seed: () => const PlayerState(duration: Duration(minutes: 1)),
    act: (bloc) => bloc.add(AudioCompleted()),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.completed,
        duration: Duration(minutes: 1),
        position: Duration(minutes: 1),
      ),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should set status to completed and auto play next surah when AudioCompleted is added and has next surah',
    build: () => playerBloc,
    seed: () => const PlayerState(
      duration: Duration(minutes: 1),
      currentSurah: tSurah1,
      surahList: tSurahList,
      editionIdentifier: tEdition,
    ),
    act: (bloc) => bloc.add(AudioCompleted()),
    expect: () => [
      const PlayerState(
        status: PlayerStatus.completed,
        duration: Duration(minutes: 1),
        position: Duration(minutes: 1),
        currentSurah: tSurah1,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.loading,
        duration: Duration(minutes: 1),
        position: Duration(minutes: 1),
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.paused,
        duration: Duration(minutes: 1),
        position: Duration(minutes: 1),
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
      const PlayerState(
        status: PlayerStatus.playing,
        duration: Duration(minutes: 1),
        position: Duration(minutes: 1),
        currentSurah: tSurah2,
        surahList: tSurahList,
        editionIdentifier: tEdition,
      ),
    ],
  );

  blocTest<PlayerBloc, PlayerState>(
    'should set status to initial when StopAudio is added',
    build: () => playerBloc,
    seed: () => const PlayerState(status: PlayerStatus.playing),
    act: (bloc) => bloc.add(StopAudio()),
    expect: () => [
      const PlayerState(status: PlayerStatus.initial),
    ],
    verify: (bloc) {
      verify(() => mockAudioPlayer.stop()).called(1);
      },
  );
}
