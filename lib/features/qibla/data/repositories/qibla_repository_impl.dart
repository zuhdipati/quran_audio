import 'package:quran_audio/features/qibla/data/datasources/compass_datasource.dart';
import 'package:quran_audio/features/qibla/domain/repositories/qibla_repository.dart';

class QiblaRepositoryImpl implements QiblaRepository {
  final CompassDataSource compassDataSource;

  QiblaRepositoryImpl({required this.compassDataSource});

  @override
  Stream<double?>? watchHeading() => compassDataSource.headingStream();
}
