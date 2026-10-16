import 'sensor_reading.dart';
import 'prediction.dart';

class ZoneStatus {
  final String zoneId;
  final String zoneName;
  final bool isOnline;
  final SensorReading? lastReading;
  final PredictionResponse? lastPrediction;
  final DateTime? lastUpdated;

  ZoneStatus({
    required this.zoneId,
    required this.zoneName,
    required this.isOnline,
    this.lastReading,
    this.lastPrediction,
    this.lastUpdated,
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
    );
  }

  /// Returns true if the last reading arrived within the last 60 seconds.
  ///
  /// Tolerant of clock drift on the Pi (which has no RTC or internet):
  /// if the timestamp is in the FUTURE relative to the phone (because
  /// the Pi's clock is ahead), we still treat the zone as online.
  bool get effectivelyOnline {
    if (!isOnline) return false;
    if (lastUpdated == null) return false;

    // Normalize to UTC for consistent comparison
    final nowUtc = DateTime.now().toUtc();
    final updatedUtc = lastUpdated!.toUtc();
    final diff = nowUtc.difference(updatedUtc);

    // Online if the reading arrived recently (within 60s ago)
    if (diff.inSeconds.abs() < 60) return true;

    // If the timestamp is in the future by up to 12 hours,
    // it's still likely just clock drift — treat as online.
    if (diff.inSeconds < 0 && diff.inSeconds.abs() < 12 * 3600) {
      return true;
    }

    return false;
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