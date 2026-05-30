import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_all_surah.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late GetAllSurah usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetAllSurah(mockQuranRepository);
  });

  final tEdition = 'ar.alafasy';

  test('should get list of surahs from the repository', () async {
    // arrange
    when(() => mockQuranRepository.getAllSurah(tEdition))
        .thenAnswer((_) async => Right(tSurahEntityList));

    // act
    final result = await usecase.call(tEdition);

    // assert
    result.fold(
      (l) => fail('Expected Right'),
      (r) => expect(r, equals(tSurahEntityList)),
    );
    verify(() => mockQuranRepository.getAllSurah(tEdition));
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
