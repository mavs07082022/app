import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class PredictionTile extends StatelessWidget {
  final CropPrediction prediction;
  final bool highlight;
  final bool showFactors;

  const PredictionTile({
    super.key,
    required this.prediction,
    this.highlight = false,
    this.showFactors = false,
  });

  static const _factorLabels = {
    'soilPh':       'Soil pH',
    'soilMoisture': 'Soil Moisture',
    'temperature':  'Temperature',
    'humidity':     'Humidity',
    'nitrogen':     'Nitrogen (N)',
    'phosphorus':   'Phosphorus (P)',
    'potassium':    'Potassium (K)',
  };

  @override
  Widget build(BuildContext context) {
    final color = Color(prediction.suitabilityColorValue);
    final isTop = prediction.isTopPick;

    // Always prioritize the Score over Confidence for display
    final String primaryNumber;
    final String primaryLabel;
    if (prediction.score > 0) {
      primaryNumber = prediction.score.toStringAsFixed(1);
      primaryLabel = 'score';
    } else if (prediction.confidence > 0) {
      primaryNumber = Fmt.pct(prediction.confidence);
      primaryLabel = 'confidence';
    } else {
      primaryNumber = '--';
      primaryLabel = 'no data';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop
              ? AppColors.primary
              : (highlight ? color : AppColors.border),
          width: isTop || highlight ? 1.6 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (prediction.rank > 0)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isTop
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${prediction.rank}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isTop ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              if (prediction.rank > 0) const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(prediction.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            prediction.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('TOP PICK',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(prediction.suitabilityDisplay,
                          style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(primaryNumber,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  Text(primaryLabel,
                      style: const TextStyle(
                          fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),

          if (showFactors && prediction.factors.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...prediction.factors.entries.map((e) {
              final label = _factorLabels[e.key] ?? e.key;
              final fs = e.value;
              final available = fs.available;
              final sc = fs.score ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(label,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: available ? sc / 100.0 : 0.0,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            !available
                                ? Colors.grey.shade300
                                : sc >= 80
                                    ? AppColors.success
                                    : sc >= 55
                                        ? AppColors.warn
                                        : AppColors.danger,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 42,
                      child: Text(
                        available ? sc.toStringAsFixed(0) : '--',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}