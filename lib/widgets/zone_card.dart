import 'package:flutter/material.dart';
import '../models/zone_status.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ZoneCard extends StatelessWidget {
  final ZoneStatus zone;
  final VoidCallback onTap;
  final Color accent;

  const ZoneCard({super.key, required this.zone, required this.onTap, required this.accent});

  void _showAdvice(BuildContext context, String status, String advice) {
    Color color = status == 'critical' ? AppColors.danger : (status == 'warning' ? AppColors.warn : AppColors.success);
    String title = status == 'critical' ? 'Critical Warning' : (status == 'warning' ? 'Attention Needed' : 'Healthy');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(status == 'critical' ? Icons.warning_rounded : (status == 'warning' ? Icons.info_rounded : Icons.check_circle_rounded), color: color, size: 28),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(advice, style: const TextStyle(fontSize: 15, height: 1.4)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final online = zone.effectivelyOnline;
    final reading = zone.lastReading;
    final prediction = zone.lastPrediction;
    final status = prediction?.status ?? 'normal';
    final advice = prediction?.advice ?? 'All sensors operating normally.';

    Color statusColor = status == 'critical' ? AppColors.danger : (status == 'warning' ? AppColors.warn : AppColors.success);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Container(height: 5, decoration: BoxDecoration(gradient: LinearGradient(colors: [accent, accent.withOpacity(0.5)]))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.agriculture, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(zone.zoneName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: online ? AppColors.success : AppColors.danger, shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  // FIXED: Using zone.fetchedAt
                                  Text(online ? 'Live • ${Fmt.ago(zone.fetchedAt)}' : 'Offline', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: online ? AppColors.success : AppColors.danger)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (online && prediction != null)
                          GestureDetector(
                            onTap: () => _showAdvice(context, status, advice),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), shape: BoxShape.circle),
                              child: Icon(status == 'normal' ? Icons.check_circle_rounded : Icons.warning_rounded, color: statusColor, size: 24),
                            ),
                          ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (reading != null) ...[
                      Row(
                        children: [
                          _mini('🌡️', reading.airTemperatureC != null ? '${Fmt.one(reading.airTemperatureC!)}°' : '--', 'Air T'),
                          _mini('💧', reading.airHumidityPct != null ? '${Fmt.one(reading.airHumidityPct!)}%' : '--', 'Humid'),
                          _mini('🌱', '${Fmt.one(reading.soilTemperatureC)}°', 'Soil T'),
                          _mini('💦', '${Fmt.one(reading.soilMoisturePct)}%', 'Moist'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (prediction != null && prediction.predictions.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                          child: Row(
                            children: [
                              const Icon(Icons.sensors_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Best: ${prediction.predictions.first.displayName} (${prediction.predictions.first.score.toStringAsFixed(1)} pts)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}