import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
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
      // GoRoute(
      //   path: '/surah/:surahId',
      //   name: 'surah_audio',
      //   pageBuilder: (context, state) {
      //     final documentId = state.pathParameters['surahId']!;
      //     return CupertinoPage(child: SurahAudio(documentId: documentId));
      //   },
      // ),
    ],
  );
}
