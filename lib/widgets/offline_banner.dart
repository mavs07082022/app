import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime? cacheTimestamp;
  final bool isStale;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    this.cacheTimestamp,
    this.isStale = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final color = isStale ? AppColors.danger : AppColors.warn;
    final icon = isStale
        ? Icons.warning_amber_rounded
        : Icons.cloud_off_rounded;
    final title = isStale
        ? 'Data is out of date'
        : 'Offline — showing cached data';
    final subtitle = cacheTimestamp != null
        ? 'Last synced ${Fmt.ago(cacheTimestamp)}'
        : 'No cached data available';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, color: color),
              tooltip: 'Retry',
            ),
        ],
      ),
    );
  }
}