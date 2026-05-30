import 'injector.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  await configureDependencies(sl);
}


Future<void> configureDependencies(GetIt sl) async {
  // ==================== External ====================
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Box>(() => Hive.box(quranBox));

  // ==================== Core ====================
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl<InternetConnection>()),
  );

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
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ==================== Use Cases ====================
  sl.registerLazySingleton(() => GetAllEdition(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetAllSurah(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetSurah(sl<QuranRepository>()));
}
