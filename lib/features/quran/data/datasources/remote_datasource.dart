import 'package:quran_audio/core/utils/app_logger.dart';

import 'package:dio/dio.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/quran/data/models/edition_model.dart';
import 'package:quran_audio/features/quran/data/models/surah_model.dart';
import 'package:quran_audio/core/error/error_keys.dart';

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

        Map<String, dynamic>? bitrateDir;
        for (final dir in rootContents) {
          if (dir is Map<String, dynamic> && dir['name'] == '128') {
            bitrateDir = dir;
            break;
          }
        }

        if (bitrateDir == null) {
          throw GeneralException(message: ErrorKeys.noAudioEditions);
        }

        final editionDirs = bitrateDir['contents'] as List<dynamic>;

        // the cdn listing is the source of truth for playable surah audio
        final identifiers = editionDirs
            .where((dir) => dir['type'] == 'directory')
            .map((dir) => dir['name'] as String)
            .toList();

        final namedEditions = await _getNamedAudioEditions();

        final editions = identifiers
            .map(
              (identifier) =>
                  namedEditions[identifier] ??
                  EditionModel.fromIdentifier(identifier),
            )
            .toList();

        editions.sort(
          (a, b) => (a.englishName ?? '').compareTo(b.englishName ?? ''),
        );

        return editions;
      } else {
        throw GeneralException(message: ErrorKeys.loadEditions);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: ErrorKeys.timeout);
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: ErrorKeys.serverError);
      }
      AppLogger.e('Network error occurred in getAllEdition', error: e);
      throw GeneralException(message: ErrorKeys.network);
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getAllEdition',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: ErrorKeys.unexpected);
    }
  }

  // readable reciter names (latin and arabic) keyed by identifier; names are
  // cosmetic, so a failure here falls back to identifier-derived names
  Future<Map<String, EditionModel>> _getNamedAudioEditions() async {
    try {
      final response = await dio.get(
        urlGetAudioEditions,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode != 200 || response.data is! Map) return {};

      final List<dynamic> data = response.data['data'] ?? [];
      return {
        for (final json in data.whereType<Map<String, dynamic>>())
          if (json['identifier'] != null)
            json['identifier'] as String: EditionModel.fromJson(json),
      };
    } catch (e) {
      AppLogger.w('Failed to load reciter names', error: e);
      return {};
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
        throw GeneralException(message: ErrorKeys.loadSurahs);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: ErrorKeys.timeout);
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: ErrorKeys.serverError);
      }
      AppLogger.e('Network error occurred in getAllSurah', error: e);
      throw GeneralException(message: ErrorKeys.network);
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getAllSurah',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: ErrorKeys.unexpected);
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
        throw GeneralException(message: ErrorKeys.loadSurah);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: ErrorKeys.timeout);
      } else if (e.type == DioExceptionType.badResponse) {
        AppLogger.e('Server error: ${e.response?.statusCode}', error: e);
        throw GeneralException(message: ErrorKeys.serverError);
      }
      AppLogger.e('Network error occurred in getSurah', error: e);
      throw GeneralException(message: ErrorKeys.network);
    } catch (e, stackTrace) {
      if (e is GeneralException) rethrow;
      AppLogger.e(
        'Unexpected error in getSurah',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: ErrorKeys.unexpected);
    }
  }
}
