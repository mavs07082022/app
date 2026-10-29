import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _zonesKey = 'cache_zones_v1';
  static const _historicalKey = 'cache_historical_v1';
  static const _zonesTimeKey = 'cache_zones_time_v1';
  static const _historicalTimeKey = 'cache_historical_time_v1';

  Future<void> saveZones(Map<String, dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_zonesKey, jsonEncode(raw));
    await prefs.setString(_zonesTimeKey, DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_zonesKey);
    if (s == null || s.isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> zonesCachedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_zonesTimeKey);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> saveHistorical(Map<String, dynamic> raw) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historicalKey, jsonEncode(raw));
    await prefs.setString(_historicalTimeKey, DateTime.now().toIso8601String());
  }

  Future<Map<String, dynamic>?> loadHistorical() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_historicalKey);
    if (s == null || s.isEmpty) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> historicalCachedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_historicalTimeKey);
    return s == null ? null : DateTime.tryParse(s);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_zonesKey);
    await prefs.remove(_historicalKey);
    await prefs.remove(_zonesTimeKey);
    await prefs.remove(_historicalTimeKey);
  }
}