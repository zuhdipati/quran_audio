import 'dart:io';

import 'package:dio/dio.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/core/utils/app_logger.dart';

/// The ambient recordings live in R2, not the app bundle. Each is fetched
/// the first time it is switched on and kept on disk, so a sound costs data
/// once and afterwards plays offline.
///
/// Files are keyed by name alone and never revalidated: a changed
/// recording needs a new file name.
abstract class AmbientSoundFileDataSource {
  /// Local path of [file], downloading it first if needed.
  Future<String> getFile(String file);
}

class AmbientSoundFileDataSourceImpl implements AmbientSoundFileDataSource {
  final Dio dio;

  /// Where the recordings are kept; resolved lazily because it comes from
  /// the platform.
  final Future<Directory> Function() directory;

  AmbientSoundFileDataSourceImpl({required this.dio, required this.directory});

  /// Downloads in flight, so tapping a sound twice fetches it once.
  final Map<String, Future<String>> _pending = {};

  @override
  Future<String> getFile(String file) =>
      // a block body, not an arrow: remove() returns this same future, and
      // whenComplete waits on whatever its callback returns
      _pending[file] ??= _fetch(file).whenComplete(() {
        _pending.remove(file);
      });

  Future<String> _fetch(String file) async {
    final folder = await directory();
    final target = File('${folder.path}/$file');
    if (await target.exists()) return target.path;

    await folder.create(recursive: true);
    // written under a temporary name so an interrupted download is never
    // mistaken for a complete file
    final partial = File('${target.path}.part');
    try {
      await dio.download(
        urlAmbientSound(file),
        partial.path,
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      await partial.rename(target.path);
      return target.path;
    } on DioException catch (e) {
      await _discard(partial);
      if (e.type == DioExceptionType.connectionError) {
        throw GeneralException(message: ErrorKeys.noInternet);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw GeneralException(message: ErrorKeys.timeout);
      }
      AppLogger.e('Failed to download ambient sound $file', error: e);
      throw GeneralException(message: ErrorKeys.playSound);
    } catch (e, stackTrace) {
      await _discard(partial);
      AppLogger.e(
        'Failed to store ambient sound $file',
        error: e,
        stackTrace: stackTrace,
      );
      throw GeneralException(message: ErrorKeys.playSound);
    }
  }

  Future<void> _discard(File partial) async {
    try {
      if (await partial.exists()) await partial.delete();
    } catch (_) {
      // a stray .part file is harmless; the next attempt overwrites it
    }
  }
}
