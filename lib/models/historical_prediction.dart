import 'sensor_reading.dart';
import 'prediction.dart';

class HistoricalPrediction {
  final String zoneId;
  final String zoneName;
  final SensorReading baselineReading;
  final List<CropPrediction> predictions;
  final String bestCrop;
  final double bestConfidence;

  HistoricalPrediction({
    required this.zoneId,
    required this.zoneName,
    required this.baselineReading,
    required this.predictions,
    required this.bestCrop,
    required this.bestConfidence,
  });

  factory HistoricalPrediction.fromJson(Map<String, dynamic> json) {
    return HistoricalPrediction(
      zoneId: (json['zone_id'] ?? '').toString(),
      zoneName: (json['zone_name'] ?? '').toString(),
      baselineReading: SensorReading.fromJson(
          (json['baseline_reading'] as Map?)?.cast<String, dynamic>() ?? {}),
      predictions: (json['predictions'] as List?)
              ?.map((e) =>
                  CropPrediction.fromJson((e as Map).cast<String, dynamic>()))
              .toList() ??
          [],
      bestCrop: (json['best_crop'] ?? '').toString(),
      bestConfidence: (json['best_confidence'] is num)
          ? (json['best_confidence'] as num).toDouble()
          : 0,
    );
  }
}

class AllHistoricalPredictions {
  final List<HistoricalPrediction> items;
  final DateTime serverTime;
  final String note;

  AllHistoricalPredictions({
    required this.items,
    required this.serverTime,
    required this.note,
  });

  factory AllHistoricalPredictions.fromJson(Map<String, dynamic> json) {
    return AllHistoricalPredictions(
      items: (json['historical'] as List?)
              ?.map((e) => HistoricalPrediction.fromJson(
                  (e as Map).cast<String, dynamic>()))
              .toList() ??
          [],
      serverTime: json['server_time'] != null
          ? DateTime.tryParse(json['server_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      note: (json['note'] ?? '').toString(),
    );
  }
}