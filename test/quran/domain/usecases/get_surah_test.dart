import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_surah.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late GetSurah usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetSurah(mockQuranRepository);
  });

  final tSurahNumber = 1;
  final tEdition = 'ar.alafasy';

  test('should get a surah detail from the repository', () async {
    // arrange
    when(() => mockQuranRepository.getSurah(tSurahNumber, tEdition))
        .thenAnswer((_) async => Right(tSurahEntity));

    // act
    final result = await usecase.call(tSurahNumber, tEdition);

    // assert
    result.fold(
      (l) => fail('Expected Right'),
      (r) => expect(r, equals(tSurahEntity)),
    );
    verify(() => mockQuranRepository.getSurah(tSurahNumber, tEdition));
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
