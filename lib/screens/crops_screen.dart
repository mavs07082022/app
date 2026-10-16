import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  static const _crops = [
    {
      'name': 'Rice',
      'emoji': '🌾',
      'color': 0xFF84CC16,
      'temp': '20 – 35 °C',
      'humidity': '70 – 95 %',
      'ph': '5.5 – 7.0',
      'moisture': '60 – 90 %',
    },
    {
      'name': 'Corn',
      'emoji': '🌽',
      'color': 0xFFF59E0B,
      'temp': '18 – 32 °C',
      'humidity': '55 – 85 %',
      'ph': '5.5 – 7.2',
      'moisture': '50 – 80 %',
    },
    {
      'name': 'Cassava',
      'emoji': '🥔',
      'color': 0xFFA16207,
      'temp': '20 – 35 °C',
      'humidity': '50 – 80 %',
      'ph': '5.0 – 7.5',
      'moisture': '40 – 75 %',
    },
    {
      'name': 'Eggplant',
      'emoji': '🍆',
      'color': 0xFF8B5CF6,
      'temp': '20 – 32 °C',
      'humidity': '55 – 85 %',
      'ph': '5.5 – 7.0',
      'moisture': '55 – 80 %',
    },
    {
      'name': 'Tomatoes',
      'emoji': '🍅',
      'color': 0xFFEF4444,
      'temp': '18 – 30 °C',
      'humidity': '50 – 80 %',
      'ph': '5.5 – 7.5',
      'moisture': '50 – 75 %',
    },
    {
      'name': 'String Beans',
      'emoji': '🫘',
      'color': 0xFF10B981,
      'temp': '18 – 30 °C',
      'humidity': '55 – 85 %',
      'ph': '5.5 – 7.5',
      'moisture': '50 – 80 %',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text('Crop Reference',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Ideal growing conditions used by the AI model',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 18),
        ..._crops.map((c) => _CropCard(crop: c)),
      ],
    );
  }
}

class _CropCard extends StatelessWidget {
  final Map<String, Object> crop;
  const _CropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    final color = Color(crop['color'] as int);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(crop['emoji'] as String,
                    style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Text(crop['name'] as String,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          _row(Icons.thermostat_rounded, 'Temperature',
              crop['temp'] as String, color),
          _row(Icons.water_drop_rounded, 'Humidity',
              crop['humidity'] as String, color),
          _row(Icons.science_rounded, 'Soil pH', crop['ph'] as String, color),
          _row(Icons.grass_rounded, 'Soil Moisture',
              crop['moisture'] as String, color),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}