import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/features/quran/data/datasources/local_datasource.dart';
import 'package:quran_audio/features/quran/data/datasources/remote_datasource.dart';
import 'package:quran_audio/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_all_surah.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_qori.dart';
import 'package:quran_audio/features/quran/domain/usecases/get_surah.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// Dio Mocks
class MockDio extends Mock implements Dio {}

// Data Source Mocks
class MockQuranRemoteDataSource extends Mock implements QuranRemoteDataSource {}
class MockQuranLocalDataSource extends Mock implements QuranLocalDataSource {}

// Repository Mocks
class MockQuranRepository extends Mock implements QuranRepository {}

// UseCase Mocks
class MockGetAllEdition extends Mock implements GetAllEdition {}
class MockGetAllSurah extends Mock implements GetAllSurah {}
class MockGetSurah extends Mock implements GetSurah {}

// Network Mocks
class MockInternetConnection extends Mock implements InternetConnection {}

// Audio Player Mocks
class MockAudioPlayer extends Mock implements ja.AudioPlayer {}
