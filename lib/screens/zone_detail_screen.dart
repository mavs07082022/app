import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/historical_prediction.dart';
import '../models/prediction.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/offline_banner.dart';
import '../widgets/comparison_card.dart';
import '../widgets/gradient_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/prediction_tile.dart';
import '../widgets/sensor_bar.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String zoneId;
  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final zone = provider.getZone(zoneId);
    final historical = provider.getHistorical(zoneId);

    if (zone == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Zone')),
        body: const Center(child: Text('Zone not found')),
      );
    }

    final reading = zone.lastReading;
    final prediction = zone.lastPrediction;
    final online = zone.effectivelyOnline;
    final (matches, total) = provider.comparePredictions(zoneId);

    return Scaffold(
      appBar: AppBar(
        title: Text(zone.zoneName.isEmpty ? zone.zoneId : zone.zoneName),
      ),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            GradientCard(
              colors: online
                  ? const [AppColors.primaryDark, AppColors.primary]
                  : const [Color(0xFF991B1B), AppColors.danger],
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      online ? Icons.wifi_tethering : Icons.wifi_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          online ? 'LIVE DATA' : 'OFFLINE',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          zone.zoneName.isEmpty ? zone.zoneId : zone.zoneName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Updated ${Fmt.ago(zone.lastUpdated)}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (provider.isUsingCache) ...[
              OfflineBanner(
                cacheTimestamp: provider.cacheTimestamp,
                isStale: provider.isCacheStale,
                onRetry: provider.refresh,
              ),
              const SizedBox(height: 18),
            ],

            if (reading == null)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.sensors_off,
                        size: 42, color: AppColors.textSecondary),
                    SizedBox(height: 10),
                    Text('Waiting for sensor data…',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else ...[
              _sectionTitle('Live Sensor Readings', Icons.sensors_rounded),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth > 500;
                  return GridView.count(
                    crossAxisCount: twoCol ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: twoCol ? 2.4 : 2.1,
                    children: [
                      MetricTile(
                        icon: Icons.thermostat_rounded,
                        label: 'Air Temp',
                        value: reading.airTemperatureC != null
                            ? '${Fmt.one(reading.airTemperatureC!)} °C'
                            : '--',
                        color: const Color(0xFFF97316),
                      ),
                      MetricTile(
                        icon: Icons.water_drop_rounded,
                        label: 'Humidity',
                        value: reading.airHumidityPct != null
                            ? '${Fmt.one(reading.airHumidityPct!)} %'
                            : '--',
                        color: const Color(0xFF3B82F6),
                      ),
                      MetricTile(
                        icon: Icons.thermostat_auto_rounded,
                        label: 'Soil Temp',
                        value: '${Fmt.one(reading.soilTemperatureC)} °C',
                        color: const Color(0xFFEF4444),
                      ),
                      MetricTile(
                        icon: Icons.grass_rounded,
                        label: 'Soil Moisture',
                        value: '${Fmt.one(reading.soilMoisturePct)} %',
                        color: const Color(0xFF14B8A6),
                      ),
                      MetricTile(
                        icon: Icons.science_rounded,
                        label: 'Soil pH',
                        value: Fmt.two(reading.soilPh),
                        color: const Color(0xFF8B5CF6),
                      ),
                      MetricTile(
                        icon: Icons.bolt_rounded,
                        label: 'EC',
                        value: '${Fmt.two(reading.soilEcMsCm)} mS/cm',
                        color: const Color(0xFFEAB308),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),

              _sectionTitle('Soil Nutrients', Icons.eco_rounded),
              const SizedBox(height: 12),
              _card(
                child: Column(
                  children: [
                    SensorBar(
                      label: 'Nitrogen (N)',
                      value: reading.soilNMgKg,
                      min: 0,
                      max: 250,
                      unit: 'mg/kg',
                      color: const Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 14),
                    SensorBar(
                      label: 'Phosphorus (P)',
                      value: reading.soilPMgKg,
                      min: 0,
                      max: 150,
                      unit: 'mg/kg',
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 14),
                    SensorBar(
                      label: 'Potassium (K)',
                      value: reading.soilKMgKg,
                      min: 0,
                      max: 300,
                      unit: 'mg/kg',
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 14),
                    SensorBar(
                      label: 'Salinity',
                      value: reading.soilSalinity,
                      min: 0,
                      max: 5,
                      unit: 'dS/m',
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              if (prediction != null && prediction.predictions.isNotEmpty) ...[
                _sectionTitle(
                    'AI Crop Ranking', Icons.auto_awesome_rounded),
                const SizedBox(height: 4),
                const Text(
                  'Weighted agronomic fit to current sensor readings',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                ...prediction.predictions.map(
                  (p) => PredictionTile(
                    prediction: p,
                    highlight: p.isTopPick,
                    showFactors: true,
                  ),
                ),
              ],

              if (prediction != null && historical != null) ...[
                const SizedBox(height: 26),
                _sectionTitle('Live vs Historical Comparison',
                    Icons.compare_arrows_rounded),
                const SizedBox(height: 4),
                const Text(
                  'How does the current sensor reading match the model\'s baseline?',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                _comparisonSummaryCard(matches, total),
                const SizedBox(height: 12),
                ..._buildComparisons(
                    prediction.predictions, historical.predictions),
              ] else if (historical != null) ...[
                const SizedBox(height: 22),
                _sectionTitle('Historical Baseline', Icons.history_rounded),
                const SizedBox(height: 12),
                ...historical.predictions.map(
                  (p) => PredictionTile(
                    prediction: p,
                    highlight: p.crop == historical.bestCrop,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _comparisonSummaryCard(int matches, int total) {
    final pct = total == 0 ? 0.0 : matches / total;
    final color = pct >= 0.8
        ? AppColors.success
        : pct >= 0.5
            ? AppColors.warn
            : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.analytics_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prediction Agreement',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  '$matches of $total crops match the historical baseline',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            Fmt.pct(pct),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildComparisons(
    List<CropPrediction> live,
    List<CropPrediction> hist,
  ) {
    final widgets = <Widget>[];
    for (final lp in live) {
      CropPrediction? hp;
      try {
        hp = hist.firstWhere((h) => h.crop == lp.crop);
      } catch (_) {
        hp = null;
      }
      if (hp == null) continue;
      widgets.add(ComparisonCard(live: lp, historical: hp));
    }
    return widgets;
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}