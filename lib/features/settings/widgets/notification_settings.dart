import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/providers/settings_provider.dart';

class NotificationSettings extends StatelessWidget {
  final List<NotificationSetting> settings;
  final Function(String, bool) onSettingChanged;

  const NotificationSettings({
    Key? key,
    required this.settings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final appSettings = settingsProvider.settings;
    
    return Column(
      children: [
        const SizedBox(height: 8),
        _NotificationSettingItem(
          title: 'Price Alerts',
          icon: Icons.price_change,
          enabled: appSettings.priceAlertsEnabled,
          onChanged: (value) {
            settingsProvider.updatePriceAlertsEnabled(value);
            onSettingChanged('price_alerts', value);
          },
        ),
        _NotificationSettingItem(
          title: 'Market Updates',
          icon: Icons.trending_up,
          enabled: appSettings.marketUpdatesEnabled,
          onChanged: (value) {
            settingsProvider.updateMarketUpdatesEnabled(value);
            onSettingChanged('market_updates', value);
          },
        ),
        _NotificationSettingItem(
          title: 'Prediction Notifications',
          icon: Icons.insights,
          enabled: appSettings.predictionAlertsEnabled,
          onChanged: (value) {
            settingsProvider.updatePredictionAlertsEnabled(value);
            onSettingChanged('predictions', value);
          },
        ),
        _NotificationSettingItem(
          title: 'System Notifications',
          icon: Icons.notifications,
          enabled: appSettings.systemNotificationsEnabled,
          onChanged: (value) {
            settingsProvider.updateSystemNotificationsEnabled(value);
            onSettingChanged('system', value);
          },
        ),
      ],
    );
  }
}

class _NotificationSettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool enabled;
  final Function(bool) onChanged;

  const _NotificationSettingItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

