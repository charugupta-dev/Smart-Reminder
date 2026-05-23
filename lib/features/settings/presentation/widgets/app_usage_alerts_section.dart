import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/app_alert_service.dart';

class AppUsageAlertsSection extends StatefulWidget {
  const AppUsageAlertsSection({super.key});

  @override
  State<AppUsageAlertsSection> createState() => _AppUsageAlertsSectionState();
}

class _AppUsageAlertsSectionState extends State<AppUsageAlertsSection> {
  final _appAlertService = AppAlertService();
  bool _alertsEnabled = false;
  int _snoozeDuration = 15;
  String _statusText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final permissions = await _appAlertService.checkPermissions();
    final settings = await _appAlertService.getSettings();
    final alertsEnabled = settings['alertsEnabled'] == true;
    final snoozeDuration =
        settings['snoozeDuration'] is int
            ? settings['snoozeDuration'] as int
            : 15;
    final hasAllPermissions =
        permissions.isNotEmpty && permissions.values.every((v) => v);

    if (mounted) {
      setState(() {
        _alertsEnabled = alertsEnabled;
        _snoozeDuration = snoozeDuration;

        if (permissions.isNotEmpty) {
          _statusText =
              !hasAllPermissions
                  ? '⚠️ Needs permissions'
                  : alertsEnabled
                  ? '✅ Active'
                  : '⏸️ Paused';
        } else {
          _statusText = 'Unavailable on this platform';
        }
      });
    }
  }

  Future<void> _toggleAlerts(bool value) async {
    if (value) {
      await _appAlertService.setSnoozeDuration(_snoozeDuration);
      final authorized = await _appAlertService.requestAuthorization();
      if (authorized) {
        await _appAlertService.startMonitoring();
        setState(() {
          _alertsEnabled = true;
          _statusText = '✅ Active';
        });
      } else {
        await _checkStatus();
      }
    } else {
      await _appAlertService.stopMonitoring();
      setState(() {
        _alertsEnabled = false;
        _statusText = '⏸️ Paused';
      });
    }
  }

  Future<void> _updateSnoozeDuration(int minutes) async {
    setState(() {
      _snoozeDuration = minutes;
    });
    await _appAlertService.setSnoozeDuration(minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Usage Alerts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Material(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Enable App Alerts',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Show a reminder when you open games, social media, or streaming apps while you have pending tasks.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                value: _alertsEnabled,
                onChanged: _toggleAlerts,
                activeThumbColor: AppColors.accentPrimary,
              ),
              const Divider(color: AppColors.borderGlass, height: 1),
              ListTile(
                title: const Text(
                  'Choose Monitored Apps',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
                onTap: () {
                  _appAlertService.showAppPicker();
                },
              ),
              const Divider(color: AppColors.borderGlass, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Snooze Duration',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // DropdownButtonHideUnderline(
                    //   child: DropdownButton<int>(
                    //     value: _snoozeDuration,
                    //     dropdownColor: AppColors.surfaceElevated,
                    //     borderRadius: BorderRadius.circular(12),
                    //     style: const TextStyle(
                    //       color: AppColors.accentPrimary,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //     items:
                    //         [5, 15, 30, 60].map((int value) {
                    //           return DropdownMenuItem<int>(
                    //             value: value,
                    //             child: Text('$value min'),
                    //           );
                    //         }).toList(),
                    //     onChanged: (int? newValue) {
                    //       if (newValue != null) {
                    //         _updateSnoozeDuration(newValue);
                    //       }
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderGlass, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      _statusText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alert appears when a monitored app opens and returns after snooze expires while tasks are still pending.',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
