import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/historical_prediction.dart';
import '../models/zone_status.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';

enum DataSource { live, cache, none }

class ZoneProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final CacheService _cache = CacheService();
  final ConnectivityService _connectivity = ConnectivityService();

  Timer? _pollTimer;
  StreamSubscription<bool>? _connSub;

  List<ZoneStatus> _zones = [];
  List<HistoricalPrediction> _historical = [];
  bool _isLoading = false;
  bool _isServerOnline = false;
  bool _isDeviceOnline = true;
  DataSource _source = DataSource.none;
  DateTime? _cacheTimestamp;
  String? _error;
  DateTime? _lastRefresh;

  /// Cache considered stale after this duration.
  static const Duration _cacheStaleAfter = Duration(hours: 24);

  // ---------------- Getters ----------------
  List<ZoneStatus> get zones => _zones;
  List<HistoricalPrediction> get historical => _historical;
  bool get isLoading => _isLoading;
  bool get isServerOnline => _isServerOnline;
  bool get isDeviceOnline => _isDeviceOnline;
  DataSource get source => _source;
  DateTime? get cacheTimestamp => _cacheTimestamp;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  String get baseUrl => _api.baseUrl;

  bool get isUsingCache => _source == DataSource.cache;
  bool get hasData => _zones.isNotEmpty;
  bool get isCacheStale {
    if (_cacheTimestamp == null) return false;
    return DateTime.now().difference(_cacheTimestamp!) > _cacheStaleAfter;
  }

  // ---------------- Lifecycle ----------------
  ZoneProvider() {
    _init();
  }

  Future<void> _init() async {
    // 1. Load saved server URL
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_url');
    if (saved != null && saved.isNotEmpty) {
      _api.updateBaseUrl(saved);
    }

    // 2. Load cache so UI has something to show immediately
    await _loadFromCache();

    // 3. Watch network changes for auto-retry
    _isDeviceOnline = await _connectivity.isOnline();
    _connSub = _connectivity.onStatusChange.listen((online) {
      final wasOffline = !_isDeviceOnline;
      _isDeviceOnline = online;
      notifyListeners();
      if (wasOffline && online) {
        _silentRefresh();
      }
    });

    // 4. Start polling
    startPolling();
  }

  // ---------------- Cache ----------------
  Future<void> _loadFromCache() async {
    try {
      final zonesRaw = await _cache.loadZones();
      final histRaw = await _cache.loadHistorical();
      if (zonesRaw != null) {
        _zones = AllZonesStatus.fromJson(zonesRaw).zones;
      }
      if (histRaw != null) {
        _historical = AllHistoricalPredictions.fromJson(histRaw).items;
      }
      _cacheTimestamp = await _cache.zonesCachedAt();
      if (_zones.isNotEmpty) {
        _source = DataSource.cache;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Cache load failed: $e');
    }
  }

  Future<void> clearCache() async {
    await _cache.clearAll();
    _cacheTimestamp = null;
    _source = DataSource.none;
    notifyListeners();
  }

  // ---------------- Server URL ----------------
  Future<void> setServerUrl(String url) async {
    _api.updateBaseUrl(url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
    notifyListeners();
    await refresh();
  }

  // ---------------- Polling ----------------
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      ApiConfig.pollInterval,
      (_) => _silentRefresh(),
    );
    refresh();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ---------------- Refresh ----------------
  Future<void> refresh() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _silentRefresh();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _silentRefresh() async {
    if (!_isDeviceOnline) {
      _isServerOnline = false;
      _error = 'Device offline';
      if (_zones.isNotEmpty) {
        _source = DataSource.cache;
      }
      notifyListeners();
      return;
    }

    try {
      final online = await _api.checkHealth();
      _isServerOnline = online;

      if (online) {
        final zonesRaw = await _api.fetchAllZonesRaw();

        Map<String, dynamic> histRaw;
        try {
          histRaw = await _api.fetchHistoricalRaw();
        } catch (_) {
          histRaw = {
            'historical': [],
            'server_time': DateTime.now().toIso8601String(),
            'note': '',
          };
        }

        _zones = AllZonesStatus.fromJson(zonesRaw).zones;
        _historical = AllHistoricalPredictions.fromJson(histRaw).items;
        _lastRefresh = DateTime.now();
        _source = DataSource.live;
        _cacheTimestamp = null;
        _error = null;

        await _cache.saveZones(zonesRaw);
        await _cache.saveHistorical(histRaw);
      } else {
        _error = 'Server unreachable';
        if (_zones.isEmpty) {
          await _loadFromCache();
        } else {
          _source = DataSource.cache;
        }
      }
    } catch (e) {
      _isServerOnline = false;
      _error = e.toString();
      if (_zones.isEmpty) {
        await _loadFromCache();
      } else {
        _source = DataSource.cache;
      }
    }
    notifyListeners();
  }

  // ---------------- Lookups ----------------
  ZoneStatus? getZone(String zoneId) {
    try {
      return _zones.firstWhere((z) => z.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  HistoricalPrediction? getHistorical(String zoneId) {
    try {
      return _historical.firstWhere((h) => h.zoneId == zoneId);
    } catch (_) {
      return null;
    }
  }

  (int, int) comparePredictions(String zoneId) {
    final live = getZone(zoneId)?.lastPrediction;
    final hist = getHistorical(zoneId);
    if (live == null || hist == null) return (0, 0);

    int matches = 0;
    int total = 0;
    for (final lp in live.predictions) {
      final hp = hist.predictions.firstWhere(
        (h) => h.crop == lp.crop,
        orElse: () => lp,
      );
      total++;
      if (lp.suitability == hp.suitability) matches++;
    }
    return (matches, total);
  }

  @override
  void dispose() {
    stopPolling();
    _connSub?.cancel();
    _connectivity.dispose();
    super.dispose();
  }
}