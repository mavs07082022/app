import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ComparisonCard extends StatelessWidget {
  final CropPrediction live;
  final CropPrediction historical;

  const ComparisonCard({
    super.key,
    required this.live,
    required this.historical,
  });

  @override
  Widget build(BuildContext context) {
    final match = live.suitability == historical.suitability;
    final liveColor = Color(live.suitabilityColorValue);
    final histColor = Color(historical.suitabilityColorValue);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: match ? AppColors.success.withOpacity(0.4)
                       : AppColors.warn.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: (match ? AppColors.success : AppColors.warn)
                  .withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(live.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    live.displayName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (match ? AppColors.success : AppColors.warn)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        match
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        size: 12,
                        color:
                            match ? AppColors.success : AppColors.warn,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        match ? 'MATCH' : 'DIFF',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: match ? AppColors.success : AppColors.warn,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Two-column body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _side(
                    label: 'Live Prediction',
                    icon: Icons.sensors_rounded,
                    suitability: live.suitabilityDisplay,
                    confidence: live.confidence,
                    color: liveColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: _side(
                    label: 'Historical Baseline',
                    icon: Icons.history_rounded,
                    suitability: historical.suitabilityDisplay,
                    confidence: historical.confidence,
                    color: histColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _side({
    required String label,
    required IconData icon,
    required String suitability,
    required double confidence,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          suitability,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color),
        ),
        const SizedBox(height: 3),
        Text(
          Fmt.pct(confidence),
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}