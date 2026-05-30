import 'dart:async';
import 'dart:developer';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  late final StreamSubscription<InternetStatus> _subscription;
  bool _hasDisconnected = false;

  void initialize() {
    _subscription = InternetConnection().onStatusChange.listen((status) {
      final isDisconnected = status == InternetStatus.disconnected;

      if (isDisconnected) {
        _hasDisconnected = true;
        log('No Internet Connection');
        // ToastUtils.error('No Internet Connection');
      } else if (_hasDisconnected) {
        log('Youre Online');
        // ToastUtils.success("You're Online");
      }
    });
  }

  void dispose() {
    _subscription.cancel();
  }
}
