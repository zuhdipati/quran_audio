import 'adapter.dart';

const String quranBox = 'quran_box';

Future<void> configureAdapters() async {
  await Hive.initFlutter();
}

Future<void> registerAdapters() async {
  Hive.registerAdapter(EditionModelAdapter());
}

Future<void> openBoxes() async {
  await Hive.openBox(quranBox);
}
