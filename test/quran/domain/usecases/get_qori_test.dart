import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_qori.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.dart';

void main() {
  late GetAllEdition usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetAllEdition(mockQuranRepository);
  });

  test('should get list of editions from the repository', () async {
    // arrange
    when(() => mockQuranRepository.getAllEdition())
        .thenAnswer((_) async => Right(tEditionEntityList));

    // act
    final result = await usecase.call();

    // assert
    result.fold(
      (l) => fail('Expected Right'),
      (r) => expect(r, equals(tEditionEntityList)),
    );
    verify(() => mockQuranRepository.getAllEdition());
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
