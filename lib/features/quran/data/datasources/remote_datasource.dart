import 'dart:developer';

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
        urlgetAllEdition,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return List<EditionModel>.from(
          data['data'].map((x) => EditionModel.fromJson(x)),
        );
      } else {
        throw GeneralException(message: 'Failed to load editions');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.badResponse) {
        log('Server error: ${e.response?.statusCode}');
        throw GeneralException(message: 'Server error occurred');
      }
      log(e.toString());
      throw GeneralException(message: 'Network error occurred');
    } catch (e) {
      if (e is GeneralException) rethrow;
      log(e.toString());
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
        log('Server error: ${e.response?.statusCode}');
        throw GeneralException(message: 'Server error occurred');
      }
      log(e.toString());
      throw GeneralException(message: 'Network error occurred');
    } catch (e) {
      if (e is GeneralException) rethrow;
      log(e.toString());
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
        log('Server error: ${e.response?.statusCode}');
        throw GeneralException(message: 'Server error occurred');
      }
      log(e.toString());
      throw GeneralException(message: 'Network error occurred');
    } catch (e) {
      if (e is GeneralException) rethrow;
      log(e.toString());
      throw GeneralException(message: 'An unexpected error occurred');
    }
  }
}
