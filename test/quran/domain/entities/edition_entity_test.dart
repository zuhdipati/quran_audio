import 'package:flutter_test/flutter_test.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';

void main() {
  test('splits the recitation style from the reciter name', () {
    const edition = EditionEntity(
      identifier: 'ar.abdulbasitmujawwad',
      language: 'ar',
      name: 'عبد الباسط عبد الصمد (مجوَّد)',
      englishName: 'Abdul Basit Abdus-Samad (Mujawwad)',
    );

    expect(edition.displayName, 'Abdul Basit Abdus-Samad');
    expect(edition.style, 'Mujawwad');
  });

  test('has no style when the name has no parentheses', () {
    const edition = EditionEntity(
      identifier: 'ar.alafasy',
      language: 'ar',
      name: 'مشاري العفاسي',
      englishName: 'Mishary Rashid Alafasy',
    );

    expect(edition.displayName, 'Mishary Rashid Alafasy');
    expect(edition.style, isNull);
  });
}
