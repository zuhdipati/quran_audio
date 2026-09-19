import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';

class GetTasbeehCounts {
  final TasbeehRepository repository;

  GetTasbeehCounts(this.repository);

  Future<Map<String, int>> call(DateTime day) => repository.getCounts(day);
}

class SaveTasbeehCount {
  final TasbeehRepository repository;

  SaveTasbeehCount(this.repository);

  Future<void> call(String dzikirId, int count, DateTime day) =>
      repository.saveCount(dzikirId, count, day);
}
