import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({super.key});

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  String _crop1 = 'rice';
  String _crop2 = 'corn';

  static const _crops = ['rice', 'corn', 'cassava', 'eggplant', 'tomato', 'string_beans'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final zones = provider.zones;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _crop1,
                  decoration: const InputDecoration(labelText: 'Crop A', border: OutlineInputBorder()),
                  items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (v) => setState(() => _crop1 = v!),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.compare_arrows, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _crop2,
                  decoration: const InputDecoration(labelText: 'Crop B', border: OutlineInputBorder()),
                  items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                  onChanged: (v) => setState(() => _crop2 = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: zones.length,
              itemBuilder: (ctx, i) {
                final z = zones[i];
                final pred = z.lastPrediction;
                if (pred == null) return const SizedBox();

                final p1 = pred.predictions.firstWhere((p) => p.crop == _crop1, orElse: () => pred.predictions.first);
                final p2 = pred.predictions.firstWhere((p) => p.crop == _crop2, orElse: () => pred.predictions.first);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(z.zoneName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _cropBox(p1)),
                          const SizedBox(width: 10),
                          Expanded(child: _cropBox(p2)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropBox(dynamic p) {
    final isWinner = p.score > 60;
    final color = isWinner ? AppColors.success : AppColors.warn;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(p.displayName, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text('${p.score.toStringAsFixed(1)} pts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(p.suitabilityDisplay, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}