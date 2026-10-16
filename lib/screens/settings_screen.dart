import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/zone_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController =
        TextEditingController(text: context.read<ZoneProvider>().baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _snack('URL cannot be empty');
      return;
    }
    await context.read<ZoneProvider>().setServerUrl(url);
    if (!mounted) return;
    _snack('Server URL saved', success: true);
  }

  void _snack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            success ? AppColors.success : AppColors.danger,
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cached data?'),
        content: const Text(
            'Offline data will be deleted. The app will need to '
            'reconnect to the server to display zones again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await context.read<ZoneProvider>().clearCache();
    if (!mounted) return;
    _snack('Cache cleared', success: true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ZoneProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        const Text('Settings',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),

        _sectionLabel('Server Connection'),
        const SizedBox(height: 8),
        TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Server Base URL',
            hintText: 'http://192.168.1.100:8000',
            prefixIcon: Icon(Icons.cloud_outlined),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save'),
                onPressed: _save,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Test'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: provider.refresh,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),
        _sectionLabel('Connection Status'),
        const SizedBox(height: 8),
        _statusCard(provider),

        const SizedBox(height: 22),
        _sectionLabel('Offline Data'),
        const SizedBox(height: 8),
        _offlineCard(provider),

        const SizedBox(height: 22),
        _sectionLabel('Help'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Which URL should I use?',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13)),
              SizedBox(height: 8),
              _HelpRow(
                  label: 'Android emulator',
                  value: 'http://10.0.2.2:8000'),
              _HelpRow(
                  label: 'iOS simulator',
                  value: 'http://localhost:8000'),
              _HelpRow(
                  label: 'Physical phone',
                  value: 'http://<YOUR_PC_IP>:8000'),
              SizedBox(height: 10),
              Text(
                'The phone must be on the same Wi-Fi network as the '
                'PC. Start the backend with --host 0.0.0.0 so devices '
                'can reach it.',
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        _sectionLabel('About'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crop Suitability App',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('AI-powered smart farming • v1.0.0',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5),
      );

  Widget _statusCard(ZoneProvider provider) {
    final deviceOnline = provider.isDeviceOnline;
    final serverOnline = provider.isServerOnline;
    final color = (deviceOnline && serverOnline)
        ? AppColors.success
        : AppColors.danger;
    final label = (deviceOnline && serverOnline)
        ? 'Connected'
        : (!deviceOnline ? 'Device offline' : 'Server unreachable');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
              (deviceOnline && serverOnline)
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: color,
              size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontSize: 14)),
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

  Widget _offlineCard(ZoneProvider provider) {
    final hasCache = provider.cacheTimestamp != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.save_alt_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasCache ? 'Cached data available' : 'No cached data',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasCache
                ? 'Last synced ${Fmt.ago(provider.cacheTimestamp)}'
                : 'Data will be cached after the first successful sync.',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Clear Cached Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: hasCache ? _clearCache : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final String label;
  final String value;
  const _HelpRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle,
              size: 5, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}