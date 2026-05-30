import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';
import 'package:quran_audio/features/quran/presentation/pages/surah_page.dart';
import 'package:quran_audio/features/quran/presentation/widgets/edition_bottom_sheet.dart';
import 'package:quran_audio/features/quran/presentation/widgets/surah_tile.dart';

class MockEditionBloc extends MockBloc<EditionEvent, EditionState> implements EditionBloc {}
class MockSurahListBloc extends MockBloc<SurahListEvent, SurahListState> implements SurahListBloc {}


class FakeSurahListEvent extends Fake implements SurahListEvent {}
class FakeSurahListState extends Fake implements SurahListState {}

void main() {
  late MockEditionBloc mockEditionBloc;
  late MockSurahListBloc mockSurahListBloc;

  setUpAll(() {
    registerFallbackValue(GetEditions());
    registerFallbackValue(EditionInitial());
    registerFallbackValue(FakeSurahListEvent());
    registerFallbackValue(FakeSurahListState());
  });

  setUp(() {
    mockEditionBloc = MockEditionBloc();
    mockSurahListBloc = MockSurahListBloc();
  });

  const tEdition = EditionEntity(
    identifier: 'ar.alafasy',
    language: 'ar',
    name: 'Alafasy',
    englishName: 'Mishary Rashid Alafasy',
  );

  const tSurah = SurahEntity(
    number: 1,
    name: 'Al-Fatihah',
    englishName: 'Al-Fatihah',
    englishNameTranslation: 'The Opening',
    revelationType: 'Meccan',
    numberOfAyahs: 7,
  );

  Widget makeTestableWidget(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditionBloc>.value(value: mockEditionBloc),
        BlocProvider<SurahListBloc>.value(value: mockSurahListBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: body),
      ),
    );
  }

  group('Surah Page & Data', () {
    testWidgets('should show loading indicator when fetching surahs (get data)', (WidgetTester tester) async {
      when(() => mockSurahListBloc.state).thenReturn(const SurahListLoading(currentEdition: tEdition));
      
      await tester.pumpWidget(makeTestableWidget(const SurahPage()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show list of surahs when data is loaded successfully', (WidgetTester tester) async {
      when(() => mockSurahListBloc.state).thenReturn(
        const SurahListLoaded(allSurahs: [tSurah], filteredSurahs: [tSurah], currentEdition: tEdition),
      );

      await tester.pumpWidget(makeTestableWidget(const SurahPage()));

      expect(find.byType(SurahTile), findsOneWidget);
      expect(find.text('Al-Fatihah'), findsWidgets);
    });

    testWidgets('should trigger SearchSurahs event when typing in search field', (WidgetTester tester) async {
      when(() => mockSurahListBloc.state).thenReturn(
        const SurahListLoaded(allSurahs: [tSurah], filteredSurahs: [tSurah], currentEdition: tEdition),
      );

      await tester.pumpWidget(makeTestableWidget(const SurahPage()));

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Baqarah');
      await tester.pump();

      verify(() => mockSurahListBloc.add(const SearchSurahs('Baqarah'))).called(1);
    });
  });

  group('Qori / Edition Data in Bottom Sheet', () {
    testWidgets('should show loading indicator when fetching qori (get qori)', (WidgetTester tester) async {
      when(() => mockEditionBloc.state).thenReturn(EditionLoading());
      
      await tester.pumpWidget(makeTestableWidget(const EditionBottomSheet(currentEdition: tEdition)));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show list of qori when data is loaded successfully', (WidgetTester tester) async {
      when(() => mockEditionBloc.state).thenReturn(
        const EditionLoaded(allEditions: [tEdition], filteredEditions: [tEdition]),
      );

      await tester.pumpWidget(makeTestableWidget(const EditionBottomSheet(currentEdition: tEdition)));

      expect(find.text('Mishary Rashid Alafasy'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should trigger SearchEditions event when typing in qori search field', (WidgetTester tester) async {
      when(() => mockEditionBloc.state).thenReturn(
        const EditionLoaded(allEditions: [tEdition], filteredEditions: [tEdition]),
      );

      await tester.pumpWidget(makeTestableWidget(const EditionBottomSheet(currentEdition: tEdition)));

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Sudais');
      await tester.pump();

      verify(() => mockEditionBloc.add(const SearchEditions('Sudais'))).called(1);
    });
  });
}
