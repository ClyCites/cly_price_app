import 'package:flutter/material.dart';
import '../../../core/models/settings_model.dart';

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
    return Column(
      children: [
        const SizedBox(height: 8),
        ...settings.map((setting) => _NotificationSettingItem(
              setting: setting,
              onChanged: (value) => onSettingChanged(setting.id, value),
            )),
      ],
    );
  }
}

class _NotificationSettingItem extends StatelessWidget {
  final NotificationSetting setting;
  final Function(bool) onChanged;

  const _NotificationSettingItem({
    Key? key,
    required this.setting,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            _getIconForType(setting.type),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              setting.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Switch(
            value: setting.enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.priceAlert:
        return Icons.price_change;
      case NotificationType.marketUpdate:
        return Icons.trending_up;
      case NotificationType.prediction:
        return Icons.insights;
      case NotificationType.system:
        return Icons.notifications;
    }
  }
}

