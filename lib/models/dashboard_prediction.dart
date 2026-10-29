import 'prediction.dart';

class DashboardPredictionResponse {
  final String id;
  final String timestamp;
  final String farmId;
  final String farmName;
  final Map<String, dynamic> inputConditions;
  final List<CropPrediction> predictions;
  final String? topPick;
  final double? confidenceGap;
  final String modelVersion;
  final int processingTimeMs;

  DashboardPredictionResponse({
    required this.id,
    required this.timestamp,
    required this.farmId,
    required this.farmName,
    required this.inputConditions,
    required this.predictions,
    this.topPick,
    this.confidenceGap,
    required this.modelVersion,
    required this.processingTimeMs,
  });

  factory DashboardPredictionResponse.fromJson(Map<String, dynamic> json) {
    return DashboardPredictionResponse(
      id: (json['id'] ?? '').toString(),
      timestamp: json['timestamp']?.toString() ?? '',
      farmId: (json['farmId'] ?? '').toString(),
      farmName: (json['farmName'] ?? '').toString(),
      inputConditions: (json['inputConditions'] as Map?)?.cast<String, dynamic>() ?? {},
      predictions: (json['predictions'] as List?)?.map((e) => CropPrediction.fromJson((e as Map).cast<String, dynamic>())).toList() ?? [],
      topPick: json['topPick']?.toString(),
      confidenceGap: (json['confidenceGap'] is num) ? (json['confidenceGap'] as num).toDouble() : null,
      modelVersion: (json['modelVersion'] ?? '').toString(),
      processingTimeMs: (json['processingTimeMs'] is num) ? (json['processingTimeMs'] as num).toInt() : 0,
    );
  }

  CropPrediction? get topCrop => predictions.isEmpty ? null : predictions.first;
}