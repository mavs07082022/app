import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
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

    if (zone == null) return Scaffold(appBar: AppBar(title: const Text('Zone')), body: const Center(child: Text('Zone not found')));

    final reading = zone.lastReading;
    final prediction = zone.lastPrediction;
    final online = zone.effectivelyOnline;
    final fertAdvice = prediction?.fertilizerAdvice ?? '';

    List<Widget> warnings = [];
    if (reading != null) {
      if (reading.soilNMgKg < 20) warnings.add(_buildWarning('Low Nitrogen (N)', 'Level is ${reading.soilNMgKg} mg/kg. Apply nitrogen-rich fertilizer.', AppColors.warn));
      if (reading.soilPMgKg < 15) warnings.add(_buildWarning('Low Phosphorus (P)', 'Level is ${reading.soilPMgKg} mg/kg. Apply phosphate fertilizer.', AppColors.warn));
      if (reading.soilKMgKg < 20) warnings.add(_buildWarning('Low Potassium (K)', 'Level is ${reading.soilKMgKg} mg/kg. Apply potash.', AppColors.warn));
      if (reading.soilMoisturePct < 15) warnings.add(_buildWarning('Soil is Too Dry', 'Moisture is ${reading.soilMoisturePct}%. Irrigation needed.', AppColors.danger));
    }

    return Scaffold(
      appBar: AppBar(title: Text(zone.zoneName.isEmpty ? zone.zoneId : zone.zoneName)),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (warnings.isNotEmpty) ...[
              Row(children: [const Icon(Icons.notifications_active, color: AppColors.danger, size: 20), const SizedBox(width: 8), Text('System Alerts (${warnings.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))]),
              const SizedBox(height: 10),
              ...warnings,
              const SizedBox(height: 16),
            ],
            GradientCard(
              colors: online ? const [AppColors.primaryDark, AppColors.primary] : const [Color(0xFF991B1B), AppColors.danger],
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: Icon(online ? Icons.wifi_tethering : Icons.wifi_off, color: Colors.white, size: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(online ? 'LIVE DATA' : 'OFFLINE', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(zone.zoneName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        Text('Updated ${Fmt.ago(zone.fetchedAt)}', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (reading == null)
              Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)), child: const Column(children: [Icon(Icons.sensors_off, size: 42, color: AppColors.textSecondary), SizedBox(height: 10), Text('Waiting for sensor data…', style: TextStyle(color: AppColors.textSecondary))]))
            else ...[
              _sectionTitle('Live Environment Readings', Icons.sensors_rounded),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.1,
                children: [
                  MetricTile(icon: Icons.thermostat_rounded, label: 'Air Temp', value: '${Fmt.one(reading.airTemperatureC ?? 0)} °C', color: const Color(0xFFF97316)),
                  MetricTile(icon: Icons.water_drop_rounded, label: 'Air Humidity', value: '${Fmt.one(reading.airHumidityPct ?? 0)} %', color: const Color(0xFF3B82F6)),
                  MetricTile(icon: Icons.thermostat_auto_rounded, label: 'Soil Temp', value: '${Fmt.one(reading.soilTemperatureC)} °C', color: const Color(0xFFEF4444)),
                  MetricTile(icon: Icons.grass_rounded, label: 'Soil Moisture', value: '${Fmt.one(reading.soilMoisturePct)} %', color: const Color(0xFF14B8A6)),
                ],
              ),
              const SizedBox(height: 22),
              _sectionTitle('Soil Nutrients & Chemistry', Icons.science_rounded),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _clickableNutrient(context, 'pH', Fmt.one(reading.soilPh), Colors.blue, 'pH Level', _getPhAdvice(reading.soilPh)),
                    _clickableNutrient(context, 'N', Fmt.one(reading.soilNMgKg), Colors.green, 'Nitrogen (N)', _getNPKAdvice('Nitrogen', reading.soilNMgKg, 50, 150)),
                    _clickableNutrient(context, 'P', Fmt.one(reading.soilPMgKg), Colors.orange, 'Phosphorus (P)', _getNPKAdvice('Phosphorus', reading.soilPMgKg, 20, 80)),
                    _clickableNutrient(context, 'K', Fmt.one(reading.soilKMgKg), Colors.purple, 'Potassium (K)', _getNPKAdvice('Potassium', reading.soilKMgKg, 80, 200)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (prediction != null) ...[
                _sectionTitle('AI Crop Ranking', Icons.auto_awesome_rounded),
                const SizedBox(height: 4),
                const Text('Based on real-time Temperature, Moisture, and Soil Nutrients', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                if (prediction.predictions.isEmpty)
                  const Text("AI is calculating rankings...", style: TextStyle(color: AppColors.textSecondary))
                else
                  ...prediction.predictions.map((p) => PredictionTile(prediction: p, highlight: p.isTopPick, showFactors: true)),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF93C5FD))),
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

  Widget _sectionTitle(String text, IconData icon) => Row(children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)))]);

  Widget _buildWarning(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 2), Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))])),
        ],
      ),
    );
  }

  Widget _clickableNutrient(BuildContext context, String label, String value, Color color, String title, String advice) {
    return InkWell(
      onTap: () => _showNutrientDialog(context, title, value, color, advice),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            const Icon(Icons.info_outline, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showNutrientDialog(BuildContext context, String title, String value, Color color, String advice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.eco_rounded, color: color, size: 28), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)))]),
        content: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Current Level:", style: TextStyle(color: AppColors.textSecondary)), Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color))]),
            const Divider(height: 20),
            const Text("AI Suggestion:", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            const SizedBox(height: 6),
            Text(advice, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)))],
      ),
    );
  }

  String _getPhAdvice(double ph) {
    if (ph == 0) return "Sensor is reading 0. Make sure the YAGO sensor is buried in wet soil.";
    if (ph < 5.5) return "Soil is too acidic. AI recommends adding agricultural lime.";
    if (ph > 7.5) return "Soil is too alkaline. AI recommends adding elemental sulfur or compost.";
    return "pH level is optimal (5.5 - 7.5).";
  }

  String _getNPKAdvice(String nutrient, double value, double min, double max) {
    if (value == 0) return "Sensor is reading 0. Make sure the YAGO sensor is buried in wet soil.";
    if (value < min) return "$nutrient is LOW. AI recommends applying a fertilizer rich in $nutrient.";
    if (value > max) return "$nutrient is HIGH. Flush with water to reduce toxicity.";
    return "$nutrient is at an optimal level.";
  }
}