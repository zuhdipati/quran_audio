import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';

abstract class HadithRemoteDataSource {
  Future<List<HadithModel>> getChunk(String collectionId, int chunk);
}

class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  final Dio dio;

  HadithRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HadithModel>> getChunk(String collectionId, int chunk) async {
    if (hadithBaseUrl.isEmpty) {
      throw GeneralException(
        message: 'Hadith hosting is not configured yet',
      );
    }

    try {
      final response = await dio.get(
        urlHadithChunk(collectionId, chunk),
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode != 200) {
        throw GeneralException(message: 'Failed to load hadiths');
      }

      // R2 may serve the object as text/plain, so Dio hands back a String
      final data = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
      final list = data is List ? data : (data as Map)['hadiths'] as List;
      return list.map((e) => HadithModel.fromJson(e)).toList();
    } on GeneralException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch hadith chunk $collectionId/$chunk',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: 'Failed to load hadiths');
    }
  }
}
