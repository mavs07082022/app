import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'predictions_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart'; // <-- NEW IMPORT
import 'comparison_screen.dart';
import 'crops_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // ADDED AnalyticsScreen TO THE LIST
  static const _screens = [
    DashboardScreen(),
    PredictionsScreen(),
    HistoryScreen(),
    AnalyticsScreen(), // <-- NEW SCREEN
    ComparisonScreen(),
    CropsScreen(),
    SettingsScreen(),
  ];

  static const _titles = ['Dashboard', 'Predictions', 'History', 'Analytics', 'Compare', 'Crops', 'Settings'];
  static const _icons = [
    Icons.dashboard_outlined, Icons.psychology_outlined, Icons.show_chart, Icons.pie_chart_outline, Icons.compare_arrows, Icons.eco_outlined, Icons.settings_outlined,
  ];
  static const _selectedIcons = [
    Icons.dashboard_rounded, Icons.psychology_rounded, Icons.show_chart_rounded, Icons.pie_chart_rounded, Icons.compare_arrows_rounded, Icons.eco_rounded, Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topBar(provider),
            Expanded(child: IndexedStack(index: _index, children: _screens)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, -4))]),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_titles.length, (i) {
                  final selected = _index == i;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = i),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 7.2, // Adjusted for 7 items
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(selected ? _selectedIcons[i] : _icons[i], color: selected ? AppColors.primary : AppColors.textSecondary, size: 20),
                          const SizedBox(height: 3),
                          Text(_titles[i], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(ZoneProvider provider) {
    final statusColor = provider.isServerOnline ? AppColors.success : (provider.isUsingCache ? AppColors.warn : AppColors.danger);
    final statusLabel = provider.isServerOnline ? 'Connected' : (provider.isUsingCache ? 'Offline (cached)' : 'Disconnected');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_titles[_index], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(statusLabel, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (provider.isLoading)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(onPressed: provider.refresh, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
    );
  }
}