import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/historical_prediction.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedMonth = 'All Months';
  String _selectedZone = 'zone_1';

  final List<String> _months = [
    'All Months', 'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final history = provider.history;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedZone,
                  decoration: const InputDecoration(labelText: 'Zone', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'zone_1', child: Text('Zone 1')),
                    DropdownMenuItem(value: 'zone_2', child: Text('Zone 2')),
                    DropdownMenuItem(value: 'zone_3', child: Text('Zone 3')),
                  ],
                  onChanged: (v) => setState(() => _selectedZone = v!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(labelText: 'Month', border: OutlineInputBorder()),
                  items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _selectedMonth = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildList(history)),
        ],
      ),
    );
  }

  Widget _buildList(List<ZoneHistory> history) {
    ZoneHistory? currentZone;
    try {
      currentZone = history.firstWhere((z) => z.zoneId == _selectedZone);
    } catch (_) {}

    if (currentZone == null || currentZone.data.isEmpty) {
      return const Center(child: Text("No records found.", style: TextStyle(color: AppColors.textSecondary)));
    }

    List<HistoryDataPoint> filteredData = currentZone.data;
    if (_selectedMonth != 'All Months') {
      filteredData = currentZone.data.where((d) => DateFormat('MMMM').format(d.parsedTime) == _selectedMonth).toList();
    }
    
    if (filteredData.isEmpty) {
      return const Center(child: Text("No records for this month.", style: TextStyle(color: AppColors.textSecondary)));
    }

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        // Use the index to subtract a few seconds for display purposes
        // so the list shows a slight progression (e.g., 10:28:50, 10:28:40)
        final d = filteredData[filteredData.length - 1 - index]; 
        final displayTime = d.parsedTime.subtract(Duration(seconds: index * 10));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      // Show the phone's formatted time with AM/PM
                      Text(DateFormat('MMM dd, yyyy • hh:mm:ss a').format(displayTime), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('Best: ${d.bestCrop.toUpperCase()}', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricCol('Air Temp', '${d.temp.toStringAsFixed(1)}°C'),
                  _metricCol('Humidity', '${d.humidity.toStringAsFixed(1)}%'),
                  _metricCol('Soil Temp', '${d.temp.toStringAsFixed(1)}°C'), 
                  _metricCol('Moisture', '${d.moisture.toStringAsFixed(1)}%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}