import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('should execute all logging methods without throwing', () {
      expect(() => AppLogger.t('Trace message'), returnsNormally);
      expect(() => AppLogger.d('Debug message'), returnsNormally);
      expect(() => AppLogger.i('Info message'), returnsNormally);
      expect(() => AppLogger.w('Warning message'), returnsNormally);
      expect(() => AppLogger.e('Error message', error: Exception('test')), returnsNormally);
      expect(() => AppLogger.f('Fatal message'), returnsNormally);
    });
  });
}
