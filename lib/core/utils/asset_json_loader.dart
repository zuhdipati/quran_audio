import 'dart:convert';

import 'package:flutter/services.dart';

/// Reads bundled JSON data from `assets/data`.
class AssetJsonLoader {
  final AssetBundle bundle;

  AssetJsonLoader({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  Future<dynamic> load(String path) async {
    final raw = await bundle.loadString(path);
    return jsonDecode(raw);
  }
}
