import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/gradient_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/zone_card.dart';
import 'zone_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const zoneAccents = {
    'zone_1': AppColors.zone1,
    'zone_2': AppColors.zone2,
    'zone_3': AppColors.zone3,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();
    final online = provider.zones.where((z) => z.effectivelyOnline).length;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // ---- Hero card ----
          GradientCard(
            colors: const [AppColors.primaryDark, AppColors.primary],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.eco_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crop Suitability',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'AI-Powered Smart Farming',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: provider.refresh,
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _heroStat('Zones', '${provider.zones.length}',
                        Icons.grid_view_rounded),
                    const SizedBox(width: 12),
                    _heroStat('Online', '$online', Icons.wifi_rounded),
                    const SizedBox(width: 12),
                    _heroStat(
                      'Updated',
                      Fmt.clock(provider.lastRefresh ??
                          provider.cacheTimestamp),
                      Icons.schedule_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ---- Offline banner ----
          if (provider.isUsingCache)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OfflineBanner(
                cacheTimestamp: provider.cacheTimestamp,
                isStale: provider.isCacheStale,
                onRetry: provider.refresh,
              ),
            ),

          // ---- Device offline banner ----
          if (!provider.isDeviceOnline)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.wifi_off_rounded,
                        color: AppColors.danger, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No internet on this device',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ---- Server banner ----
          _serverBanner(context, provider),
          const SizedBox(height: 18),

          // ---- Section title ----
          Row(
            children: [
              const Text('Crop Zones',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.zones.length}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ---- Zones list ----
          if (provider.zones.isEmpty && !provider.isLoading)
            _emptyState(provider)
          else
            ...provider.zones.map(
              (z) => ZoneCard(
                zone: z,
                accent: zoneAccents[z.zoneId] ?? AppColors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ZoneDetailScreen(zoneId: z.zoneId),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              provider.isUsingCache
                  ? 'Cached data • ${Fmt.time(provider.cacheTimestamp)}'
                  : 'Last refresh: ${Fmt.time(provider.lastRefresh)}',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _serverBanner(BuildContext context, ZoneProvider provider) {
    final online = provider.isServerOnline;
    final color = online ? AppColors.success : AppColors.danger;
    final label = online
        ? 'Server online'
        : (provider.isDeviceOnline
            ? 'Server offline'
            : 'Device offline');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
                online ? Icons.cloud_done_rounded : Icons.cloud_off,
                color: color,
                size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color)),
                Text(provider.baseUrl,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(ZoneProvider provider) {
    final isOffline =
        !provider.isDeviceOnline || !provider.isServerOnline;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            isOffline ? Icons.cloud_off_rounded : Icons.sensors_off,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            isOffline ? 'No cached data available' : 'No zone data yet',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isOffline
                ? 'Connect to the farm server once to enable offline mode.'
                : 'Check your server URL in Settings.\nMake sure the backend is running.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}