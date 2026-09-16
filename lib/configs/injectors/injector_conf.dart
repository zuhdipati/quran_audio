import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:quran_audio/configs/adapters/adapter_conf.dart';
import 'package:quran_audio/core/services/connectivity_service.dart';
import 'package:quran_audio/core/utils/asset_json_loader.dart';
import 'package:quran_audio/features/dua/data/datasources/dua_local_datasource.dart';
import 'package:quran_audio/features/dua/data/repositories/dua_repository_impl.dart';
import 'package:quran_audio/features/dua/domain/repositories/dua_repository.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_daily_dua.dart';
import 'package:quran_audio/features/dua/domain/usecases/get_duas.dart';
import 'package:quran_audio/features/dua/presentation/bloc/daily_dua/daily_dua_bloc.dart';
import 'package:quran_audio/features/dua/presentation/bloc/dua/dua_bloc.dart';
import 'package:quran_audio/features/hadith/data/datasources/hadith_local_datasource.dart';
import 'package:quran_audio/features/hadith/data/repositories/hadith_repository_impl.dart';
import 'package:quran_audio/features/hadith/domain/repositories/hadith_repository.dart';
import 'package:quran_audio/features/hadith/domain/usecases/get_hadith_collection.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:quran_audio/features/hijri/data/datasources/hijri_local_datasource.dart';
import 'package:quran_audio/features/hijri/data/repositories/hijri_repository_impl.dart';
import 'package:quran_audio/features/hijri/domain/repositories/hijri_repository.dart';
import 'package:quran_audio/features/hijri/domain/usecases/convert_to_hijri.dart';
import 'package:quran_audio/features/hijri/domain/usecases/get_hijri_month.dart';
import 'package:quran_audio/features/hijri/domain/usecases/get_upcoming_events.dart';
import 'package:quran_audio/features/hijri/presentation/bloc/hijri_bloc.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_device_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/location_local_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/datasources/prayer_time_calculator_datasource.dart';
import 'package:quran_audio/features/prayer_time/data/repositories/prayer_time_repository_impl.dart';
import 'package:quran_audio/features/prayer_time/domain/repositories/prayer_time_repository.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_location.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_prayer_schedules.dart';
import 'package:quran_audio/features/prayer_time/domain/usecases/get_qibla_direction.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';
import 'package:quran_audio/features/qibla/data/datasources/compass_datasource.dart';
import 'package:quran_audio/features/qibla/data/repositories/qibla_repository_impl.dart';
import 'package:quran_audio/features/qibla/domain/repositories/qibla_repository.dart';
import 'package:quran_audio/features/qibla/domain/usecases/watch_compass_heading.dart';
import 'package:quran_audio/features/qibla/presentation/bloc/qibla_bloc.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/local_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/remote_datasource.dart';
import 'package:quran_audio/features/quran/data/repositories/ambient_sound_repository_impl.dart';
import 'package:quran_audio/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:quran_audio/features/quran/domain/repositories/ambient_sound_repository.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_all_surah.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_ambient_sounds.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_qori.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_surah.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';
import 'package:quran_audio/features/salah/data/datasources/salah_local_datasource.dart';
import 'package:quran_audio/features/salah/data/repositories/salah_repository_impl.dart';
import 'package:quran_audio/features/salah/domain/repositories/salah_repository.dart';
import 'package:quran_audio/features/salah/domain/usecases/get_salah_guide.dart';
import 'package:quran_audio/features/salah/presentation/bloc/salah_bloc.dart';
import 'package:quran_audio/features/tasbeeh/data/datasources/tasbeeh_local_datasource.dart';
import 'package:quran_audio/features/tasbeeh/data/repositories/tasbeeh_repository_impl.dart';
import 'package:quran_audio/features/tasbeeh/domain/repositories/tasbeeh_repository.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/get_dzikir_list.dart';
import 'package:quran_audio/features/tasbeeh/domain/usecases/tasbeeh_counts.dart';
import 'package:quran_audio/features/tasbeeh/presentation/bloc/tasbeeh_bloc.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {
  await configureDependencies(sl);
}

Future<void> configureDependencies(GetIt sl) async {
  // ==================== External ====================
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Box>(() => Hive.box(quranBox));
  sl.registerLazySingleton<Box>(() => Hive.box(appBox), instanceName: appBox);
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton(() => AssetJsonLoader());
  sl.registerLazySingleton(() => ConnectivityService());
  sl<ConnectivityService>().initialize();

  // ==================== Data Sources ====================
  sl.registerLazySingleton<QuranRemoteDataSource>(
    () => QuranRemoteDataSourceImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<QuranLocalDataSource>(
    () => QuranLocalDataSourceImpl(box: sl<Box>(), loader: sl()),
  );
  sl.registerLazySingleton<AmbientSoundDataSource>(
    () => AmbientSoundDataSourceImpl(loader: sl()),
  );
  sl.registerLazySingleton<HijriLocalDataSource>(
    () => HijriLocalDataSourceImpl(loader: sl()),
  );
  sl.registerLazySingleton<LocationDeviceDataSource>(
    () => LocationDeviceDataSourceImpl(),
  );
  sl.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(box: sl<Box>(instanceName: appBox)),
  );
  sl.registerLazySingleton<PrayerTimeCalculatorDataSource>(
    () => PrayerTimeCalculatorDataSourceImpl(),
  );
  sl.registerLazySingleton<CompassDataSource>(() => CompassDataSourceImpl());
  sl.registerLazySingleton<DuaLocalDataSource>(
    () => DuaLocalDataSourceImpl(loader: sl()),
  );
  sl.registerLazySingleton<HadithLocalDataSource>(
    () => HadithLocalDataSourceImpl(loader: sl()),
  );
  sl.registerLazySingleton<TasbeehLocalDataSource>(
    () => TasbeehLocalDataSourceImpl(
      loader: sl(),
      box: sl<Box>(instanceName: appBox),
    ),
  );
  sl.registerLazySingleton<SalahLocalDataSource>(
    () => SalahLocalDataSourceImpl(loader: sl()),
  );

  // ==================== Repository ====================
  sl.registerLazySingleton<QuranRepository>(
    () => QuranRepositoryImpl(
      remoteDataSource: sl<QuranRemoteDataSource>(),
      localDataSource: sl<QuranLocalDataSource>(),
      internetConnection: sl<InternetConnection>(),
    ),
  );
  sl.registerLazySingleton<AmbientSoundRepository>(
    () => AmbientSoundRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<HijriRepository>(
    () => HijriRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<PrayerTimeRepository>(
    () => PrayerTimeRepositoryImpl(
      deviceDataSource: sl(),
      localDataSource: sl(),
      calculatorDataSource: sl(),
      hijriDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<QiblaRepository>(
    () => QiblaRepositoryImpl(compassDataSource: sl()),
  );
  sl.registerLazySingleton<DuaRepository>(
    () => DuaRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<HadithRepository>(
    () => HadithRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TasbeehRepository>(
    () => TasbeehRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<SalahRepository>(
    () => SalahRepositoryImpl(localDataSource: sl()),
  );

  // ==================== Use Cases ====================
  sl.registerLazySingleton(() => GetAllEdition(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetAllSurah(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetSurah(sl<QuranRepository>()));
  sl.registerLazySingleton(() => GetAmbientSounds(sl()));
  sl.registerLazySingleton(() => ConvertToHijri(sl()));
  sl.registerLazySingleton(() => GetHijriMonth(sl()));
  sl.registerLazySingleton(() => GetUpcomingEvents(sl()));
  sl.registerLazySingleton(() => GetLocation(sl()));
  sl.registerLazySingleton(() => GetPrayerSchedules(sl()));
  sl.registerLazySingleton(() => GetQiblaDirection(sl()));
  sl.registerLazySingleton(() => WatchCompassHeading(sl()));
  sl.registerLazySingleton(() => GetDuas(sl()));
  sl.registerLazySingleton(() => GetDailyDua(sl()));
  sl.registerLazySingleton(() => GetHadithCollection(sl()));
  sl.registerLazySingleton(() => GetDzikirList(sl()));
  sl.registerLazySingleton(() => GetTasbeehCounts(sl()));
  sl.registerLazySingleton(() => SaveTasbeehCount(sl()));
  sl.registerLazySingleton(() => GetSalahGuide(sl()));

  // ==================== BLoC ====================
  sl.registerFactory(() => EditionBloc(getAllEdition: sl<GetAllEdition>()));
  sl.registerFactory(() => SurahListBloc(getAllSurah: sl<GetAllSurah>()));
  sl.registerFactory(() => PlayerBloc());
  sl.registerFactory(() => AmbientBloc(getAmbientSounds: sl()));
  sl.registerFactory(
    () => PrayerTimeBloc(getLocation: sl(), getPrayerSchedules: sl()),
  );
  sl.registerFactory(() => CalendarBloc(getPrayerSchedules: sl()));
  sl.registerFactory(
    () => HijriBloc(
      convertToHijri: sl(),
      getHijriMonth: sl(),
      getUpcomingEvents: sl(),
    ),
  );
  sl.registerFactory(
    () => QiblaBloc(getQiblaDirection: sl(), watchCompassHeading: sl()),
  );
  sl.registerFactory(() => DuaBloc(getDuas: sl()));
  sl.registerFactory(() => DailyDuaBloc(getDailyDua: sl()));
  sl.registerFactory(() => HadithBloc(getHadithCollection: sl()));
  sl.registerFactory(
    () => TasbeehBloc(
      getDzikirList: sl(),
      getTasbeehCounts: sl(),
      saveTasbeehCount: sl(),
    ),
  );
  sl.registerFactory(() => SalahBloc(getSalahGuide: sl()));
}
