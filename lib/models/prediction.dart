import 'sensor_reading.dart';

class CropPrediction {
  final String crop;
  final String suitability;
  final double confidence; // 0.0 - 1.0
  final double score;      // 0 - 100
  final int rank;
  final Map<String, double> probabilities;
  final Map<String, FactorScore> factors;

  CropPrediction({
    required this.crop,
    required this.suitability,
    required this.confidence,
    this.score = 0.0,
    this.rank = 0,
    this.probabilities = const {},
    this.factors = const {},
  });

  factory CropPrediction.fromJson(Map<String, dynamic> json) {
    final cropName = (json['crop'] ?? json['cropName'] ?? '').toString();

    double? asD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final rawScore = asD(json['score']);
    final rawConf = asD(json['confidence']);

    double score;
    double confidence;
    if (rawScore != null && rawScore > 0) {
      score = rawScore;
      confidence = rawConf ?? (rawScore / 100.0);
    } else if (rawConf != null && rawConf > 0) {
      confidence = rawConf;
      score = rawConf * 100.0;
    } else {
      score = 0.0;
      confidence = 0.0;
    }

    final probsRaw = json['probabilities'];
    final probs = <String, double>{};
    if (probsRaw is Map) {
      probsRaw.forEach((k, v) {
        final d = asD(v);
        if (d != null) probs[k.toString()] = d;
      });
    }

    final factorsRaw = json['factors'];
    final factors = <String, FactorScore>{};
    if (factorsRaw is Map) {
      factorsRaw.forEach((k, v) {
        if (v is Map) {
          factors[k.toString()] =
              FactorScore.fromJson(v.cast<String, dynamic>());
        }
      });
    }

    final rankVal = json['rank'];
    final rank = (rankVal is num) ? rankVal.toInt() : 0;

    return CropPrediction(
      crop: cropName,
      suitability: (json['suitability'] ?? '').toString(),
      confidence: confidence,
      score: score,
      rank: rank,
      probabilities: probs,
      factors: factors,
    );
  }

  String get emoji {
    switch (crop.toLowerCase()) {
      case 'rice': return '🌾';
      case 'corn': return '🌽';
      case 'cassava': return '🥔';
      case 'eggplant': return '🍆';
      case 'tomatoes': return '🍅';
      case 'string_beans':
      case 'string beans': return '🫘';
      default: return '🌱';
    }
  }

  String get displayName {
    switch (crop.toLowerCase()) {
      case 'rice': return 'Rice';
      case 'corn': return 'Corn';
      case 'cassava': return 'Cassava';
      case 'eggplant': return 'Eggplant';
      case 'tomatoes': return 'Tomatoes';
      case 'string_beans':
      case 'string beans': return 'String Beans';
      default: return crop;
    }
  }

  String get suitabilityDisplay {
    switch (suitability.toLowerCase()) {
      case 'suitable': return 'Suitable';
      case 'moderately_suitable':
      case 'moderately suitable':
      case 'moderate': return 'Moderate';
      case 'not_suitable':
      case 'not suitable': return 'Not Suitable';
      default: return suitability;
    }
  }

  int get suitabilityColorValue {
    switch (suitability.toLowerCase()) {
      case 'suitable': return 0xFF22C55E;
      case 'moderately_suitable':
      case 'moderately suitable':
      case 'moderate': return 0xFFF59E0B;
      case 'not_suitable':
      case 'not suitable': return 0xFFEF4444;
      default: return 0xFF94A3B8;
    }
  }

  bool get isTopPick => rank == 1;
  bool get hasData => score > 0.0 || confidence > 0.0;
}

class FactorScore {
  final double? value;
  final double? idealMin;
  final double? idealMax;
  final double? score;
  final String status;

  FactorScore({
    this.value,
    this.idealMin,
    this.idealMax,
    this.score,
    required this.status,
  });

  factory FactorScore.fromJson(Map<String, dynamic> json) {
    double? d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }
    return FactorScore(
      value: d(json['value']),
      idealMin: d(json['idealMin']),
      idealMax: d(json['idealMax']),
      score: d(json['score']),
      status: (json['status'] ?? 'unavailable').toString(),
    );
  }

  bool get available => score != null;
}

class PredictionResponse {
  final String zoneId;
  final DateTime timestamp;
  final SensorReading reading;
  final List<CropPrediction> predictions;
  final String bestCrop;
  final double bestConfidence;

  PredictionResponse({
    required this.zoneId,
    required this.timestamp,
    required this.reading,
    required this.predictions,
    required this.bestCrop,
    required this.bestConfidence,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    final listRaw = json['predictions'] as List?;
    final parsed = listRaw
            ?.map((e) =>
                CropPrediction.fromJson((e as Map).cast<String, dynamic>()))
            .toList() ??
        [];

    // Sort by rank if backend didn't already (defensive)
    if (parsed.isNotEmpty && parsed.every((p) => p.rank == 0)) {
      parsed.sort((a, b) => b.score.compareTo(a.score));
    }

    double bestConf = 0.0;
    final bc = json['best_confidence'];
    if (bc is num) {
      bestConf = bc.toDouble();
    } else if (parsed.isNotEmpty) {
      bestConf = parsed.first.confidence;
    }

    return PredictionResponse(
      zoneId: (json['zone_id'] ?? '').toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reading: SensorReading.fromJson(
          (json['reading'] as Map?)?.cast<String, dynamic>() ?? {}),
      predictions: parsed,
      bestCrop: (json['best_crop'] ?? '').toString(),
      bestConfidence: bestConf,
    );
  }

  CropPrediction? get topPick =>
      predictions.isEmpty ? null : predictions.first;
}