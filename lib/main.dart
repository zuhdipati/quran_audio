import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quran_audio/configs/adapters/adapter_conf.dart';
import 'package:quran_audio/configs/injectors/injector_conf.dart';
import 'package:quran_audio/core/routes/app_routes.dart';
import 'package:quran_audio/core/themes/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/dua/presentation/bloc/daily_dua/daily_dua_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/prayer_time/prayer_time_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/ambient/ambient_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/edition/edition_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/player/player_bloc.dart';
import 'package:quran_audio/features/quran/presentation/bloc/surah_list/surah_list_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    // init hive
    AppLogger.i('Initializing Hive...');
    await configureAdapters();
    await registerAdapters();
    await openBoxes();

    // init di
    AppLogger.i('Initializing Dependency Injection...');
    await initInjector();

    AppLogger.i('App Initialization Complete');
  } catch (e, stackTrace) {
    AppLogger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
  }

  runApp(const QuranAudioApp());
}

final _router = AppRoutes().router;

class QuranAudioApp extends StatelessWidget {
  const QuranAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditionBloc>(create: (context) => sl<EditionBloc>()),
        BlocProvider<SurahListBloc>(create: (context) => sl<SurahListBloc>()),
        BlocProvider<PlayerBloc>(create: (context) => sl<PlayerBloc>()),
        BlocProvider<AmbientBloc>(create: (context) => sl<AmbientBloc>()),
        BlocProvider<PrayerTimeBloc>(create: (context) => sl<PrayerTimeBloc>()),
        BlocProvider<DailyDuaBloc>(create: (context) => sl<DailyDuaBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Quran Audio',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: AppTheme.appTheme,
      ),
    );
  }
}
