import 'dart:async';
import 'package:quran_audio/core/utils/app_logger.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  late final StreamSubscription<InternetStatus> _subscription;
  bool _hasDisconnected = false;

  void initialize() {
    _subscription = InternetConnection().onStatusChange.listen((status) {
      final isDisconnected = status == InternetStatus.disconnected;

      if (isDisconnected) {
        _hasDisconnected = true;
        AppLogger.w('No Internet Connection');
        // ToastUtils.error('No Internet Connection');
      } else if (_hasDisconnected) {
        AppLogger.i('Youre Online');
        // ToastUtils.success("You're Online");
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
