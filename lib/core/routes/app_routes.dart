import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_audio/features/quran/domain/entities/surah_entity.dart';
import 'package:quran_audio/features/quran/presentation/pages/audio_player_page.dart';
import 'package:quran_audio/features/quran/presentation/pages/surah_page.dart';

class AppRoutes {
  GoRouter get router => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'surah_list',
        pageBuilder: (context, state) =>
            CupertinoPage(child: const SurahPage()),
      ),
      GoRoute(
        path: '/player',
        name: 'player',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          final surah = args['surah'] as SurahEntity;
          final editionIdentifier = args['editionIdentifier'] as String;
          final surahList = args['surahList'] as List<SurahEntity>;
          return CupertinoPage(
            child: AudioPlayerPage(
              surah: surah,
              editionIdentifier: editionIdentifier,
              surahList: surahList,
            ),
          );
        },
      ),
    ],
  );
}
