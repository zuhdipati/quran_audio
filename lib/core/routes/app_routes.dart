import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/configs/injectors/injector_conf.dart';
import 'package:quran_audio/core/routes/route_paths.dart';
import 'package:quran_audio/features/dua/domain/entities/dua_entity.dart';
import 'package:quran_audio/features/dua/presentation/bloc/dua/dua_bloc.dart';
import 'package:quran_audio/features/dua/presentation/pages/dua_detail_page.dart';
import 'package:quran_audio/features/dua/presentation/pages/dua_page.dart';
import 'package:quran_audio/features/hadith/domain/entities/hadith_entity.dart';
import 'package:quran_audio/features/hadith/presentation/bloc/hadith_bloc.dart';
import 'package:quran_audio/features/hadith/presentation/pages/hadith_detail_page.dart';
import 'package:quran_audio/features/hadith/presentation/pages/hadith_page.dart';
import 'package:quran_audio/features/hijri/presentation/bloc/hijri_bloc.dart';
import 'package:quran_audio/features/hijri/presentation/pages/hijri_page.dart';
import 'package:quran_audio/features/home/presentation/pages/home_page.dart';
import 'package:quran_audio/features/prayer_time/presentation/bloc/calendar/calendar_bloc.dart';
import 'package:quran_audio/features/prayer_time/presentation/pages/calendar_page.dart';
import 'package:quran_audio/features/qibla/presentation/bloc/qibla_bloc.dart';
import 'package:quran_audio/features/qibla/presentation/pages/qibla_page.dart';
import 'package:quran_audio/features/quran/domain/entities/edition_entity.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/pages/audio_player_page.dart';
import 'package:quran_audio/features/quran/presentation/pages/surah_page.dart';
import 'package:quran_audio/features/salah/presentation/bloc/salah_bloc.dart';
import 'package:quran_audio/features/salah/presentation/pages/salah_page.dart';
import 'package:quran_audio/features/settings/presentation/pages/settings_page.dart';
import 'package:quran_audio/features/tasbeeh/presentation/bloc/tasbeeh_bloc.dart';
import 'package:quran_audio/features/tasbeeh/presentation/pages/tasbeeh_page.dart';

class AppRoutes {
  GoRouter get router => GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        pageBuilder: (context, state) => const CupertinoPage(child: HomePage()),
      ),
      GoRoute(
        path: RoutePaths.quran,
        name: 'surah_list',
        pageBuilder: (context, state) =>
            const CupertinoPage(child: SurahPage()),
      ),
      GoRoute(
        path: RoutePaths.player,
        name: 'player',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final surah = args['surah'] as SurahEntity;
          final editionIdentifier = args['editionIdentifier'] as String;
          final surahList = args['surahList'] as List<SurahEntity>;
          final edition = args['edition'] as EditionEntity?;
          return CupertinoPage(
            child: AudioPlayerPage(
              surah: surah,
              editionIdentifier: editionIdentifier,
              surahList: surahList,
              edition: edition,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.hijri,
        name: 'hijri',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<HijriBloc>(),
            child: const HijriPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.qibla,
        name: 'qibla',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<QiblaBloc>(),
            child: const QiblaPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.tasbeeh,
        name: 'tasbeeh',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<TasbeehBloc>(),
            child: const TasbeehPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.calendar,
        name: 'calendar',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<CalendarBloc>(),
            child: const CalendarPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.dua,
        name: 'dua',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<DuaBloc>(),
            child: const DuaPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.duaDetail,
        name: 'dua_detail',
        pageBuilder: (context, state) =>
            CupertinoPage(child: DuaDetailPage(dua: state.extra as DuaEntity)),
      ),
      GoRoute(
        path: RoutePaths.hadith,
        name: 'hadith',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<HadithBloc>(),
            child: const HadithPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.hadithDetail,
        name: 'hadith_detail',
        pageBuilder: (context, state) => CupertinoPage(
          child: HadithDetailPage(hadith: state.extra as HadithEntity),
        ),
      ),
      GoRoute(
        path: RoutePaths.salah,
        name: 'salah',
        pageBuilder: (context, state) => CupertinoPage(
          child: BlocProvider(
            create: (_) => sl<SalahBloc>(),
            child: const SalahPage(),
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        pageBuilder: (context, state) =>
            const CupertinoPage(child: SettingsPage()),
      ),
    ],
  );
}
