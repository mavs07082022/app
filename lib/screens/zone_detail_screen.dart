import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/offline_banner.dart';
import '../widgets/gradient_card.dart';
import '../widgets/metric_tile.dart';
import '../widgets/prediction_tile.dart';

class ZoneDetailScreen extends StatelessWidget {
  final String zoneId;
  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final zone = provider.getZone(zoneId);

    if (zone == null) {
      return Scaffold(appBar: AppBar(title: const Text('Zone')), body: const Center(child: Text('Zone not found')));
    }

    final reading = zone.lastReading;
    final prediction = zone.lastPrediction;
    final online = zone.effectivelyOnline;
    final status = prediction?.status ?? 'normal';
    final advice = prediction?.advice ?? '';
    final fertAdvice = prediction?.fertilizerAdvice ?? '';
    Color statusColor = status == 'critical' ? AppColors.danger : (status == 'warning' ? AppColors.warn : AppColors.success);

    return Scaffold(
      appBar: AppBar(title: Text(zone.zoneName.isEmpty ? zone.zoneId : zone.zoneName)),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (prediction != null && status != 'normal')
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: statusColor.withOpacity(0.4), width: 1.5)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: statusColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status == 'critical' ? 'Critical Warning' : 'Attention Needed', style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(advice, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            GradientCard(
              colors: online ? const [AppColors.primaryDark, AppColors.primary] : const [Color(0xFF991B1B), AppColors.danger],
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                    child: Icon(online ? Icons.wifi_tethering : Icons.wifi_off, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(online ? 'LIVE DATA' : 'OFFLINE', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(zone.zoneName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text('Updated ${Fmt.ago(zone.fetchedAt)}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (provider.isUsingCache) ...[
              OfflineBanner(cacheTimestamp: provider.cacheTimestamp, isStale: provider.isCacheStale, onRetry: provider.refresh),
              const SizedBox(height: 18),
            ],
            if (reading == null)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                child: const Column(children: [Icon(Icons.sensors_off, size: 42, color: AppColors.textSecondary), SizedBox(height: 10), Text('Waiting for sensor data…', style: TextStyle(color: AppColors.textSecondary))]),
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
                      MetricTile(icon: Icons.thermostat_rounded, label: 'Air Temp', value: reading.airTemperatureC != null ? '${Fmt.one(reading.airTemperatureC!)} °C' : '--', color: const Color(0xFFF97316)),
                      MetricTile(icon: Icons.water_drop_rounded, label: 'Humidity', value: reading.airHumidityPct != null ? '${Fmt.one(reading.airHumidityPct!)} %' : '--', color: const Color(0xFF3B82F6)),
                      MetricTile(icon: Icons.thermostat_auto_rounded, label: 'Soil Temp', value: '${Fmt.one(reading.soilTemperatureC)} °C', color: const Color(0xFFEF4444)),
                      MetricTile(icon: Icons.grass_rounded, label: 'Soil Moisture', value: '${Fmt.one(reading.soilMoisturePct)} %', color: const Color(0xFF14B8A6)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              if (prediction != null && prediction.predictions.isNotEmpty) ...[
                _sectionTitle('AI Crop Ranking', Icons.auto_awesome_rounded),
                const SizedBox(height: 4),
                const Text('Based strictly on real-time Temperature and Moisture', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ...prediction.predictions.map((p) => PredictionTile(prediction: p, highlight: p.isTopPick, showFactors: true)),
                
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.science_rounded, color: Color(0xFF2563EB), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Fertilizer & Action Advisory", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(fertAdvice, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))]);
  }
}