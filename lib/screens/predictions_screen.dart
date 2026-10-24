import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prediction.dart';
import '../models/zone_status.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/prediction_tile.dart';

class PredictionsScreen extends StatelessWidget {
  const PredictionsScreen({super.key});

  static const zoneAccents = {
    'zone_1': AppColors.zone1,
    'zone_2': AppColors.zone2,
    'zone_3': AppColors.zone3,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final zones = provider.zones;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('Best Crop per Zone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Ranked by agronomic fit to live sensor readings',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 18),
          if (zones.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No prediction data yet',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ...zones.map((z) => _ZoneBlock(
                zone: z,
                accent: zoneAccents[z.zoneId] ?? AppColors.primary,
              )),
        ],
      ),
    );
  }
}

class _ZoneBlock extends StatelessWidget {
  final ZoneStatus zone;
  final Color accent;
  const _ZoneBlock({required this.zone, required this.accent});

  @override
  Widget build(BuildContext context) {
    final prediction = zone.lastPrediction;
    final reading = zone.lastReading;
    final List<CropPrediction> ranked = prediction?.predictions ?? [];
    final top = ranked.isNotEmpty ? ranked.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.4)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: zone.effectivelyOnline
                              ? AppColors.success
                              : AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          zone.zoneName.isEmpty
                              ? zone.zoneId
                              : zone.zoneName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        Fmt.ago(zone.lastUpdated),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  if (top != null) ...[
                    const SizedBox(height: 12),
                    _topPickBanner(top),
                  ],

                  const SizedBox(height: 14),

                  if (ranked.isEmpty)
                    const Text('No prediction yet',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))
                  else
                    ...ranked.map((p) => PredictionTile(
                          prediction: p,
                          highlight: p.isTopPick,
                          showFactors: p.isTopPick,
                        )),

                  if (reading != null) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    _sensorSnapshot(reading),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topPickBanner(CropPrediction top) {
    final displayScore = top.score > 0
        ? top.score.toStringAsFixed(1)
        : (top.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(top.emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECOMMENDED NOW',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0),
                ),
                const SizedBox(height: 2),
                Text(
                  top.displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayScore,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
              Text('score',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sensorSnapshot(dynamic reading) {
    Widget cell(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textSecondary)),
            ],
          ),
        );

    return Row(
      children: [
        cell('pH*', Fmt.two(reading.soilPh)),
        cell('Moist', '${Fmt.one(reading.soilMoisturePct)}%'),
        cell('Temp', '${Fmt.one(reading.soilTemperatureC)}°'),
        cell('N*', Fmt.one(reading.soilNMgKg)),
        cell('P*', Fmt.one(reading.soilPMgKg)),
        cell('K*', Fmt.one(reading.soilKMgKg)),
      ],
    );
  }
}