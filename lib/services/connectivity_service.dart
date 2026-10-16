import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity_plus and exposes a simple stream of
/// "online / offline" booleans.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Streams `true` when the phone has any usable network, `false` otherwise.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  /// One-shot check.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return _isOnline(results);
  }

  bool _isOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  void dispose() {
    _sub?.cancel();
  }
}