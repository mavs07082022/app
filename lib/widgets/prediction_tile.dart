import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../theme/app_theme.dart';

class PredictionTile extends StatelessWidget {
  final CropPrediction prediction;
  final bool highlight;
  final bool showFactors;

  const PredictionTile({super.key, required this.prediction, this.highlight = false, this.showFactors = false});

  @override
  Widget build(BuildContext context) {
    final color = Color(prediction.suitabilityColorValue);
    final isTop = prediction.isTopPick;
    final primaryNumber = prediction.score > 0 ? prediction.score.toStringAsFixed(1) : '0.0';

    String getExplanation() {
      if (prediction.score >= 70) return "This crop is highly suitable because the current soil moisture, pH, and NPK levels perfectly match its ideal growing environment.";
      if (prediction.score >= 40) return "This crop is moderately suitable. The soil lacks some nutrients (NPK) or has an imbalanced pH for optimal growth.";
      return "This crop is NOT suitable. The current soil is too dry, too acidic/alkaline, or severely lacks essential nutrients for this specific crop to survive.";
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: highlight ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isTop ? AppColors.primary : (highlight ? color : AppColors.border), width: isTop || highlight ? 1.6 : 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              if (prediction.rank > 0)
                Container(
                  width: 26, height: 26, alignment: Alignment.center,
                  decoration: BoxDecoration(color: isTop ? AppColors.primary : AppColors.border.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                  child: Text('${prediction.rank}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: isTop ? Colors.white : AppColors.textSecondary)),
                ),
              if (prediction.rank > 0) const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(prediction.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(prediction.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                        if (isTop) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                            child: const Text('TOP PICK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(prediction.suitabilityDisplay, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(primaryNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                  const Text('score', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            const Text("Why this rank?", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 4),
            Text(getExplanation(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }
}