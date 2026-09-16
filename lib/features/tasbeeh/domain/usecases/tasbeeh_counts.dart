import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';

class GetTasbeehCounts {
  final TasbeehRepository repository;

  GetTasbeehCounts(this.repository);

  Future<Map<String, int>> call() => repository.getCounts();
}

class SaveTasbeehCount {
  final TasbeehRepository repository;

  SaveTasbeehCount(this.repository);

  Future<void> call(String dzikirId, int count) =>
      repository.saveCount(dzikirId, count);
}
