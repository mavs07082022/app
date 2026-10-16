import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/dashboard_prediction.dart';
import '../models/historical_prediction.dart';
import '../models/prediction.dart';
import '../models/sensor_reading.dart';
import '../models/zone_status.dart';

class ApiService {
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  String _baseUrl;
  String get baseUrl => _baseUrl;
  void updateBaseUrl(String url) => _baseUrl = url;

  Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl${ApiConfig.health}'))
          .timeout(ApiConfig.timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchAllZonesRaw() async {
    final res = await _get(ApiConfig.zones);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<AllZonesStatus> fetchAllZones() async {
    final raw = await fetchAllZonesRaw();
    return AllZonesStatus.fromJson(raw);
  }

  Future<Map<String, dynamic>> fetchHistoricalRaw() async {
    final res = await _get(ApiConfig.historical);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<AllHistoricalPredictions> fetchHistorical() async {
    final raw = await fetchHistoricalRaw();
    return AllHistoricalPredictions.fromJson(raw);
  }

  Future<PredictionResponse> predict(SensorReading reading) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl${ApiConfig.predict}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reading.toJson()),
          )
          .timeout(ApiConfig.timeout);
      if (res.statusCode != 200) {
        throw ApiException('Prediction failed (HTTP ${res.statusCode})');
      }
      return PredictionResponse.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timed out');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Weighted fuzzy scoring endpoint — returns ranked crops + factor breakdown.
  Future<DashboardPredictionResponse> predictDashboard({
    required double soilPh,
    required double soilMoisture,
    required double temperature,
    double? humidity,
    double rainfall = 0.0,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    String? farmId,
  }) async {
    try {
      final body = <String, dynamic>{
        'soilPh': soilPh,
        'soilMoisture': soilMoisture,
        'temperature': temperature,
        'rainfall': rainfall,
        if (humidity != null) 'humidity': humidity,
        if (nitrogen != null) 'nitrogen': nitrogen,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (farmId != null) 'farmId': farmId,
      };

      final res = await http
          .post(
            Uri.parse('$_baseUrl/api/predict/dashboard'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      if (res.statusCode != 200) {
        throw ApiException(
            'Dashboard prediction failed (HTTP ${res.statusCode})');
      }
      return DashboardPredictionResponse.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timed out');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<http.Response> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(ApiConfig.timeout);
      if (res.statusCode != 200) {
        throw ApiException('Failed to load $path (HTTP ${res.statusCode})');
      }
      return res;
    } on SocketException {
      throw ApiException('Cannot reach server at $_baseUrl');
    } on TimeoutException {
      throw ApiException('Request timed out');
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}