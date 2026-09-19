import 'dart:async';

import 'package:quran_audio/core/locale/l10n.dart';
import 'package:quran_audio/core/utils/app_logger.dart';
import 'package:quran_audio/core/utils/toast_utils.dart';

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
        ToastUtils.showError(currentL10n().errorMessage('noInternet'));
      } else if (_hasDisconnected) {
        AppLogger.i('Back online');
        ToastUtils.showSuccess(currentL10n().backOnline);
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
