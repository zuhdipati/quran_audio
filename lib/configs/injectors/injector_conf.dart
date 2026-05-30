import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:quran_audio/configs/adapters/adapter_conf.dart';
import 'package:quran_audio/core/services/connectivity_service.dart';
import 'package:quran_audio/features/quran/data/datasources/local_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/remote_datasource.dart';
import 'package:quran_audio/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_all_surah.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_qori.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_surah.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  await configureDependencies(sl);
}

Future<void> configureDependencies(GetIt sl) async {
  // ==================== External ====================
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Box>(() => Hive.box(quranBox));
  sl.registerLazySingleton(() => ConnectivityService());
  sl<ConnectivityService>().initialize();

  // ==================== Data Sources ====================
  sl.registerLazySingleton<QuranRemoteDataSource>(
    () => QuranRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(box: sl<Box>()),
  );

  // ==================== Repository ====================
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      remoteDataSource: sl<QuranRemoteDataSource>(),
      localDataSource: sl<QuranLocalDataSource>(),
    ),
  );

  // ==================== Use Cases ====================
  sl.registerLazySingleton(() => GetAllEdition(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetAllSurah(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetSurah(sl<QuranRepository>()));

  // ==================== BLoC ====================
  sl.registerFactory(() => EditionBloc(getAllEdition: sl<GetAllEdition>()));
  sl.registerFactory(() => SurahListBloc(getAllSurah: sl<GetAllSurah>()));
  sl.registerFactory(() => PlayerBloc());
}
