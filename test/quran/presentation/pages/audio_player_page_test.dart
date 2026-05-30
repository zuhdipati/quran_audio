import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_event.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_state.dart';
import 'package:quran_audio/features/quran/presentation/pages/audio_player_page.dart';

class MockPlayerBloc extends MockBloc<PlayerEvent, PlayerState> implements PlayerBloc {}

class FakePlayerEvent extends Fake implements PlayerEvent {}
class FakePlayerState extends Fake implements PlayerState {}

void main() {
  late MockPlayerBloc mockPlayerBloc;

  setUpAll(() {
    registerFallbackValue(FakePlayerEvent());
    registerFallbackValue(FakePlayerState());
  });

  setUp(() {
    mockPlayerBloc = MockPlayerBloc();
  });

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

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<PlayerBloc>.value(
      value: mockPlayerBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  group('Audio Player Page', () {
    testWidgets('should fire LoadSurah on init and display basic UI', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.loading,
        currentSurah: tSurah1,
        editionIdentifier: tEdition,
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      // verify LoadSurah was added
      verify(() => mockPlayerBloc.add(const LoadSurah(tSurah1, editionIdentifier: tEdition, surahList: tSurahList))).called(1);

      // Verify UI elements
      expect(find.text('Surah Al-Fatihah'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget); 
    });

    testWidgets('should display pause icon when playing and trigger PauseAudio on tap', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah1,
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final pauseIcon = find.byIcon(Icons.pause);
      expect(pauseIcon, findsOneWidget);

      await tester.tap(pauseIcon);
      await tester.pump();

      verify(() => mockPlayerBloc.add(PauseAudio())).called(1);
    });

    testWidgets('should display play icon when paused and trigger ResumeAudio on tap', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.paused,
        currentSurah: tSurah1,
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final playIcon = find.byIcon(Icons.play_arrow);
      expect(playIcon, findsOneWidget);

      await tester.tap(playIcon);
      await tester.pump();

      verify(() => mockPlayerBloc.add(ResumeAudio())).called(1);
    });

    testWidgets('should trigger PlayAudio when status is initial on tap', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.initial,
        currentSurah: tSurah1,
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final playIcon = find.byIcon(Icons.play_arrow);
      expect(playIcon, findsOneWidget);

      await tester.tap(playIcon);
      await tester.pump();

      verify(() => mockPlayerBloc.add(PlayAudio())).called(1);
    });

    testWidgets('should trigger NextSurah when next icon is tapped and has next surah', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah1,
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final nextIcon = find.byIcon(Icons.skip_next);
      expect(nextIcon, findsOneWidget);

      await tester.tap(nextIcon);
      await tester.pump();

      verify(() => mockPlayerBloc.add(NextSurah())).called(1);
    });

    testWidgets('should trigger PreviousSurah when previous icon is tapped and has previous surah', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        currentSurah: tSurah2, 
        surahList: tSurahList,
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah2,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final prevIcon = find.byIcon(Icons.skip_previous);
      expect(prevIcon, findsOneWidget);

      await tester.tap(prevIcon);
      await tester.pump();

      verify(() => mockPlayerBloc.add(PreviousSurah())).called(1);
    });

    testWidgets('should trigger SeekAudio for rewind 10 seconds', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(seconds: 60),
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final replayIcon = find.byIcon(Icons.replay_10);
      expect(replayIcon, findsOneWidget);

      await tester.tap(replayIcon);
      await tester.pump();

      // current 30s - 10s = 20s
      verify(() => mockPlayerBloc.add(const SeekAudio(Duration(seconds: 20)))).called(1);
    });

    testWidgets('should trigger SeekAudio for fast forward 10 seconds', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        position: Duration(seconds: 30),
        duration: Duration(seconds: 60),
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final forwardIcon = find.byIcon(Icons.forward_10);
      expect(forwardIcon, findsOneWidget);

      await tester.tap(forwardIcon);
      await tester.pump();

      // current 30s + 10s = 40s
      verify(() => mockPlayerBloc.add(const SeekAudio(Duration(seconds: 40)))).called(1);
    });

    testWidgets('should not exceed duration when fast forwarding', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        position: Duration(seconds: 55),
        duration: Duration(seconds: 60),
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      await tester.tap(find.byIcon(Icons.forward_10));
      await tester.pump();

      // capped at duration
      verify(() => mockPlayerBloc.add(const SeekAudio(Duration(seconds: 60)))).called(1);
    });

    testWidgets('should not go below zero when rewinding', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState(
        status: PlayerStatus.playing,
        position: Duration(seconds: 5),
        duration: Duration(seconds: 60),
      ));

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      await tester.tap(find.byIcon(Icons.replay_10));
      await tester.pump();

      // floored at 0
      verify(() => mockPlayerBloc.add(const SeekAudio(Duration.zero))).called(1);
    });

    testWidgets('should trigger StopAudio and pop when back button is pressed', (tester) async {
      when(() => mockPlayerBloc.state).thenReturn(const PlayerState());

      await tester.pumpWidget(makeTestableWidget(
        const AudioPlayerPage(
          surah: tSurah1,
          editionIdentifier: tEdition,
          surahList: tSurahList,
        ),
      ));

      final backBtn = find.byIcon(Icons.arrow_back);
      expect(backBtn, findsOneWidget);

      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      verify(() => mockPlayerBloc.add(StopAudio())).called(1);
      expect(find.byType(AudioPlayerPage), findsNothing); // Popped
    });
  });
}
