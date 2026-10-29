import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/historical_prediction.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
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

    // 1. Get the data for the selected zone
    ZoneHistory? currentZone;
    try {
      currentZone = history.firstWhere((z) => z.zoneId == _selectedZone);
    } catch (_) {}

    // 2. Filter by month
    List<HistoryDataPoint> filteredData = currentZone?.data ?? [];
    if (_selectedMonth != 'All Months') {
      filteredData = filteredData.where((d) => DateFormat('MMMM').format(d.parsedTime) == _selectedMonth).toList();
    }

    // 3. Calculate Averages
    double avgMoisture = 0, avgSoilTemp = 0, avgAirTemp = 0, avgHumidity = 0;
    if (filteredData.isNotEmpty) {
      double sumM = 0, sumST = 0, sumAT = 0, sumH = 0;
      for (var d in filteredData) {
        sumM += d.moisture;
        sumST += d.temp; // Assuming temp is soil temp
        sumAT += d.temp; // Assuming temp is air temp for this UI
        sumH += d.humidity;
      }
      avgMoisture = sumM / filteredData.length;
      avgSoilTemp = sumST / filteredData.length;
      avgAirTemp = sumAT / filteredData.length;
      avgHumidity = sumH / filteredData.length;
    }

    // 4. Calculate Crop Distribution (how many times a crop was best)
    Map<String, int> cropCounts = {};
    for (var d in filteredData) {
      cropCounts[d.bestCrop] = (cropCounts[d.bestCrop] ?? 0) + 1;
    }
    // Sort by most frequent
    var sortedCrops = cropCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FILTERS
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
          const SizedBox(height: 20),

          if (filteredData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text("No analytics data available for this filter.", style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else ...[
            // KPI CARDS
            Row(
              children: [
                _kpiCard("Avg Moisture", "${avgMoisture.toStringAsFixed(1)}%", AppColors.primary, Icons.water_drop),
                const SizedBox(width: 10),
                _kpiCard("Avg Soil Temp", "${avgSoilTemp.toStringAsFixed(1)}°C", AppColors.danger, Icons.thermostat),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _kpiCard("Avg Air Temp", "${avgAirTemp.toStringAsFixed(1)}°C", AppColors.warn, Icons.wb_sunny),
                const SizedBox(width: 10),
                _kpiCard("Avg Humidity", "${avgHumidity.toStringAsFixed(1)}%", AppColors.accent, Icons.cloud),
              ],
            ),
            const SizedBox(height: 24),

            // MOISTURE TREND CHART
            const Text("Moisture Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.only(right: 16, top: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(filteredData.length, (i) => FlSpot(i.toDouble(), filteredData[i].moisture)),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 4,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // CROP DISTRIBUTION CHART
            const Text("Crop Prediction Frequency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                children: sortedCrops.map((entry) {
                  double percentage = (entry.value / filteredData.length) * 100;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Text("${percentage.toStringAsFixed(1)}% (${entry.value} times)", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }
}