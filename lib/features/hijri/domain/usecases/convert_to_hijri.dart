import 'package:quran_audio/features/hijri/domain/entities/hijri_date_entity.dart';
import 'package:quran_audio/features/hijri/domain/repositories/hijri_repository.dart';

class ConvertToHijri {
  final HijriRepository repository;

  ConvertToHijri(this.repository);

  HijriDateEntity call(DateTime date) => repository.toHijri(date);
}
