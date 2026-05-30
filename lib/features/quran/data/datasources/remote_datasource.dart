import 'package:quran_audio/core/utils/app_logger.dart';

import 'package:dio/dio.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';

abstract class QuranRemoteDataSource {
  Future<List<EditionModel>> getAllEdition();
  Future<List<SurahModel>> getAllSurah(String edition);
  Future<SurahModel> getSurah(int surahNumber, String edition);
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final Dio dio;

  QuranRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EditionModel>> getAllEdition() async {
    try {
      final response = await dio.get(
        urlGetCdnInfo,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final rootDir = data[0] as Map<String, dynamic>;
        final rootContents = rootDir['contents'] as List<dynamic>;

        final bitrateDir = rootContents.firstWhere(
          (dir) => dir['name'] == '128',
          orElse: () => null,
        );

        if (bitrateDir == null) {
          throw GeneralException(message: 'No audio editions found');
        }

        final editionDirs = bitrateDir['contents'] as List<dynamic>;

        final editions = editionDirs
            .where((dir) => dir['type'] == 'directory')
            .map((dir) => EditionModel.fromIdentifier(dir['name'] as String))
            .toList();

        editions.sort(
          (a, b) => (a.englishName ?? '').compareTo(b.englishName ?? ''),
        );

        return editions;
      } else {
        throw GeneralException(message: 'Failed to load editions');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: 'Server error occurred');
      }
      AppLogger.e('Network error occurred in getAllEdition', error: e);
      throw GeneralException(message: 'Network error occurred');
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getAllEdition',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<List<SurahModel>> getAllSurah(String edition) async {
    try {
      final response = await dio.get(
        urlGetAllSurah(edition),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return List<SurahModel>.from(
          (data['data']['surahs'] as List).map((x) => SurahModel.fromJson(x)),
        );
      } else {
        throw GeneralException(message: 'Failed to load surahs');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: 'Server error occurred');
      }
      AppLogger.e('Network error occurred in getAllSurah', error: e);
      throw GeneralException(message: 'Network error occurred');
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getAllSurah',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'An unexpected error occurred');
    }
  }

  @override
  Future<SurahModel> getSurah(int surahNumber, String edition) async {
    try {
      final response = await dio.get(
        urlGetSurah(surahNumber.toString(), edition),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return SurahModel.fromJson(data['data']);
      } else {
        throw GeneralException(message: 'Failed to load surah');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: 'Server error occurred');
      }
      AppLogger.e('Network error occurred in getSurah', error: e);
      throw GeneralException(message: 'Network error occurred');
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getSurah',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'An unexpected error occurred');
    }
  }
}
