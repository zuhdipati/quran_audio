import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/core/error/exception.dart';

void main() {
  group('GeneralException', () {
    test('should return message when toString is called', () {
      final exception = GeneralException(message: 'Test message');
      expect(exception.toString(), 'Test message');
    });
  });
}
