import 'package:flutter/material.dart';
import 'package:quran_audio/configs/adapters/adapter_conf.dart';
import 'package:quran_audio/configs/injectors/injector_conf.dart';
import 'package:quran_audio/core/routes/app_routes.dart';
import 'package:quran_audio/core/themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init hive
  await configureAdapters();
  await registerAdapters();
  await openBoxes();

  // init di
  await initInjector();

  runApp(const QuranAudioApp());
}

class QuranAudioApp extends StatelessWidget {
  const QuranAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes().router,
      theme: AppTheme.appTheme,
    );
  }
}
