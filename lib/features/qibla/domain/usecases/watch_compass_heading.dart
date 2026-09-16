import 'package:quran_audio/features/qibla/domain/repositories/qibla_repository.dart';

class WatchCompassHeading {
  final QiblaRepository repository;

  WatchCompassHeading(this.repository);

  Stream<double?>? call() => repository.watchHeading();
}
