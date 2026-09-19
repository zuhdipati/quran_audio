import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quran_audio/core/const/endpoints.dart';
import 'package:quran_audio/core/error/error_keys.dart';
import 'package:quran_audio/core/error/exception.dart';
import 'package:quran_audio/features/quran/data/datasources/ambient_sound_file_datasource.dart';

import '../helpers/test_helper.dart';

void main() {
  late MockDio dio;
  late Directory root;
  late AmbientSoundFileDataSourceImpl dataSource;

  setUp(() async {
    dio = MockDio();
    root = await Directory.systemTemp.createTemp('ambient_test');
    dataSource = AmbientSoundFileDataSourceImpl(
      dio: dio,
      directory: () async => Directory('${root.path}/ambient_sounds'),
    );
  });

  tearDown(() => root.delete(recursive: true));

  void stubDownload({Duration delay = Duration.zero}) {
    when(
      () => dio.download(any(), any(), options: any(named: 'options')),
    ).thenAnswer((i) async {
      await Future<void>.delayed(delay);
      await File(i.positionalArguments[1] as String).writeAsString('mp3');
      return Response(requestOptions: RequestOptions(), statusCode: 200);
    });
  }

  test('downloads from R2 once, then serves the file from disk', () async {
    stubDownload();

    final first = await dataSource.getFile('rain.mp3');
    final second = await dataSource.getFile('rain.mp3');

    expect(first, '${root.path}/ambient_sounds/rain.mp3');
    expect(second, first);
    expect(await File(first).readAsString(), 'mp3');
    verify(
      () => dio.download(
        urlAmbientSound('rain.mp3'),
        '$first.part',
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('taps during a download share it', () async {
    stubDownload(delay: const Duration(milliseconds: 20));

    final paths = await Future.wait([
      dataSource.getFile('rain.mp3'),
      dataSource.getFile('rain.mp3'),
    ]);

    expect(paths[0], paths[1]);
    verify(
      () => dio.download(any(), any(), options: any(named: 'options')),
    ).called(1);
  });

  test('offline says so and leaves nothing half-written behind', () async {
    when(
      () => dio.download(any(), any(), options: any(named: 'options')),
    ).thenAnswer((i) async {
      await File(i.positionalArguments[1] as String).writeAsString('m');
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );
    });

    await expectLater(
      dataSource.getFile('rain.mp3'),
      throwsA(
        isA<GeneralException>().having(
          (e) => e.message,
          'message',
          ErrorKeys.noInternet,
        ),
      ),
    );
    final folder = Directory('${root.path}/ambient_sounds');
    expect(folder.listSync(), isEmpty);

    // and the next tap tries again rather than reusing the failure
    stubDownload();
    expect(await dataSource.getFile('rain.mp3'), '${folder.path}/rain.mp3');
  });
}
