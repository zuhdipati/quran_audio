import 'package:dio/dio.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/features/hadith/data/models/hadith_model.dart';
import 'package:quran_audio/core/error/error_keys.dart';

/// Hadith per page, for browsing and for search alike.
const int hadithPageSize = 20;

/// The hadith API (workers/hadith-api). Everything is read live: search
/// covers the full text of every collection, which no local cache could.
abstract class HadithRemoteDataSource {
  Future<List<HadithCollectionModel>> getCollections();

  /// [page] is 1-based.
  Future<HadithPageModel> getPage(String collectionId, int page);

  /// Every collection, or only [collectionId] when given. Inside one
  /// collection a bare number opens that hadith instead of searching.
  Future<HadithPageModel> search(
    String query, {
    String? collectionId,
    required int page,
  });
}

class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  final Dio dio;

  HadithRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HadithCollectionModel>> getCollections() async {
    final data = await _getJson(
      urlHadithCollections,
      errorKey: ErrorKeys.loadHadithCollections,
    );
    return (data['data'] as List)
        .map((e) => HadithCollectionModel.fromJson(e))
        .toList();
  }

  @override
  Future<HadithPageModel> getPage(String collectionId, int page) async {
    final data = await _getJson(
      urlHadithPage(collectionId),
      query: {'page': page, 'limit': hadithPageSize},
      errorKey: ErrorKeys.loadHadiths,
    );
    return HadithPageModel.fromJson(data);
  }

  @override
  Future<HadithPageModel> search(
    String query, {
    String? collectionId,
    required int page,
  }) async {
    final data = await _getJson(
      urlHadithSearch,
      query: {
        'q': query,
        'collection': ?collectionId,
        'page': page,
        'limit': hadithPageSize,
      },
      errorKey: ErrorKeys.searchHadith,
    );
    return HadithPageModel.fromJson(data);
  }

  Future<Map<String, dynamic>> _getJson(
    String url, {
    Map<String, dynamic>? query,
    required String errorKey,
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: query,
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );
      if (response.statusCode != 200 || response.data is! Map) {
        throw GeneralException(message: errorKey);
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: ErrorKeys.timeout);
      }
      if (e.type == DioExceptionType.connectionError) {
        throw GeneralException(message: ErrorKeys.noInternet);
      }
      AppLogger.e('Hadith API request failed: $url', error: e);
      throw GeneralException(message: errorKey);
    } on GeneralException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Unexpected hadith API response: $url',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: errorKey);
    }
  }
}
