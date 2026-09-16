import 'adapter.dart';

const String quranBox = 'quran_box';
const String appBox = 'app_box';

Future<void> configureAdapters() async {
  await Hive.initFlutter();
}

Future<void> registerAdapters() async {
  Hive.registerAdapter(EditionModelAdapter());
}

Future<void> openBoxes() async {
  await Hive.openBox(quranBox);
  await Hive.openBox(appBox);
}
