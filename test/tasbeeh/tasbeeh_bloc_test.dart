import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/tasbeeh/domain/entities/dzikir_entity.dart';
import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/get_dzikir_list.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/tasbeeh_counts.dart';
import 'package:quran_audio/features/tasbeeh/presentation/bloc/tasbeeh_bloc.dart';

class MockTasbeehRepository extends Mock implements TasbeehRepository {}

void main() {
  late MockTasbeehRepository repository;

  const tList = [
    DzikirEntity(
      id: 'tasbih',
      arabic: 'سُبْحَانَ اللّٰهِ',
      latin: 'Subhanallah',
      translation: 'Maha Suci Allah',
      target: 33,
    ),
    DzikirEntity(
      id: 'istighfar',
      arabic: 'أَسْتَغْفِرُ اللّٰهَ',
      latin: 'Astaghfirullah',
      translation: 'Aku memohon ampun',
      target: 100,
    ),
  ];

  setUp(() {
    repository = MockTasbeehRepository();
    when(
      () => repository.getDzikirList(),
    ).thenAnswer((_) async => const Right(tList));
    when(() => repository.getCounts()).thenAnswer((_) async => {'tasbih': 32});
    when(() => repository.saveCount(any(), any())).thenAnswer((_) async {});
  });

  TasbeehBloc build() => TasbeehBloc(
    getDzikirList: GetDzikirList(repository),
    getTasbeehCounts: GetTasbeehCounts(repository),
    saveTasbeehCount: SaveTasbeehCount(repository),
  );

  blocTest<TasbeehBloc, TasbeehState>(
    'restores saved counts and completes a round of 33',
    build: build,
    act: (bloc) async {
      bloc.add(TasbeehStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TasbeehIncremented());
    },
    verify: (bloc) {
      expect(bloc.state.count, 33);
      expect(bloc.state.completedRounds, 1);
      expect(bloc.state.roundProgress, 33);
      verify(() => repository.saveCount('tasbih', 33)).called(1);
    },
  );

  blocTest<TasbeehBloc, TasbeehState>(
    'keeps separate counts per dzikir and resets only the current one',
    build: build,
    act: (bloc) async {
      bloc.add(TasbeehStarted());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TasbeehDzikirSelected(1));
      bloc.add(TasbeehIncremented());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TasbeehReset());
    },
    verify: (bloc) {
      expect(bloc.state.counts['istighfar'], 0);
      expect(bloc.state.counts['tasbih'], 32);
    },
  );
}
