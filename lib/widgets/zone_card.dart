import 'package:flutter/material.dart';

import '../models/historical_prediction.dart';
import '../models/prediction.dart';
import '../models/zone_status.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ZoneCard extends StatelessWidget {
  final ZoneStatus zone;
  final HistoricalPrediction? historical;
  final VoidCallback onTap;
  final Color accent;

  const ZoneCard({
    super.key,
    required this.zone,
    required this.onTap,
    required this.accent,
    this.historical,
  });

  @override
  Widget build(BuildContext context) {
    final online = zone.effectivelyOnline;
    final reading = zone.lastReading;
    final prediction = zone.lastPrediction;
    final hist = historical;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.5)],
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accent.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.agriculture,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone.zoneName.isEmpty
                                    ? zone.zoneId
                                    : zone.zoneName,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: online
                                          ? AppColors.success
                                          : AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    online
                                        ? 'Live • ${Fmt.ago(zone.lastUpdated)}'
                                        : 'Offline',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: online
                                            ? AppColors.success
                                            : AppColors.danger),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: Colors.grey.shade400),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (reading == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.sensors_off,
                                  color: AppColors.textSecondary, size: 28),
                              SizedBox(height: 6),
                              Text('Waiting for sensor data…',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          _mini(
                            '🌡️',
                            reading.airTemperatureC != null
                                ? '${Fmt.one(reading.airTemperatureC!)}°'
                                : '--',
                            'Air Temp',
                          ),
                          _mini(
                            '💧',
                            reading.airHumidityPct != null
                                ? '${Fmt.one(reading.airHumidityPct!)}%'
                                : '--',
                            'Humidity',
                          ),
                          _mini(
                            '🌱',
                            '${Fmt.one(reading.soilMoisturePct)}%',
                            'Soil Moist',
                          ),
                          _mini('⚗️', Fmt.two(reading.soilPh), 'pH'),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (prediction != null &&
                          prediction.predictions.isNotEmpty)
                        _predRow(
                          icon: Icons.sensors_rounded,
                          label: 'LIVE',
                          text: _topPickText(prediction.predictions),
                          color: AppColors.primary,
                        ),

                      if (hist != null && hist.predictions.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _predRow(
                          icon: Icons.history_rounded,
                          label: 'HIST',
                          text:
                              'Best: ${_cap(hist.bestCrop)} (${Fmt.pct(hist.bestConfidence)})',
                          color: AppColors.accent,
                        ),
                      ],
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

  String _topPickText(List<CropPrediction> predictions) {
    if (predictions.isEmpty) return 'No prediction';
    final top = predictions.first;
    if (top.score > 0) {
      return '${top.displayName} — ${top.score.toStringAsFixed(1)} pts';
    }
    if (top.confidence > 0) {
      return 'Best: ${_cap(top.crop)} (${Fmt.pct(top.confidence)})';
    }
    return 'Waiting for data…';
  }

  Widget _predRow({
    required IconData icon,
    required String label,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }

  Widget _mini(String emoji, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}