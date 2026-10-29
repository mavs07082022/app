import 'sensor_reading.dart';
import 'prediction.dart';

class ZoneStatus {
  final String zoneId;
  final String zoneName;
  final bool isOnline;
  final SensorReading? lastReading;
  final PredictionResponse? lastPrediction;
  final DateTime? lastUpdated;
  final DateTime? fetchedAt;

  ZoneStatus({
    required this.zoneId,
    required this.zoneName,
    required this.isOnline,
    this.lastReading,
    this.lastPrediction,
    this.lastUpdated,
    this.fetchedAt,
  });

  factory ZoneStatus.fromJson(Map<String, dynamic> json) {
    return ZoneStatus(
      zoneId: (json['zone_id'] ?? '').toString(),
      zoneName: (json['zone_name'] ?? '').toString(),
      isOnline: json['is_online'] == true,
      lastReading: json['last_reading'] != null
          ? SensorReading.fromJson(
              (json['last_reading'] as Map).cast<String, dynamic>())
          : null,
      lastPrediction: json['last_prediction'] != null
          ? PredictionResponse.fromJson(
              (json['last_prediction'] as Map).cast<String, dynamic>())
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
      fetchedAt: DateTime.now(), 
    );
  }

  bool get effectivelyOnline {
    return isOnline && lastReading != null;
  }
}

class AllZonesStatus {
  final List<ZoneStatus> zones;
  final DateTime serverTime;

  AllZonesStatus({required this.zones, required this.serverTime});

  factory AllZonesStatus.fromJson(Map<String, dynamic> json) {
    return AllZonesStatus(
      zones: (json['zones'] as List?)
              ?.map((e) =>
                  ZoneStatus.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          [],
      serverTime: json['server_time'] != null
          ? DateTime.tryParse(json['server_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}