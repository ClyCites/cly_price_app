import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/settings_provider.dart';

class NotificationSettingsWidget extends StatelessWidget {
  const NotificationSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive alerts about price changes and market updates'),
          value: settingsProvider.settings.notificationsEnabled,
          onChanged: (value) {
            settingsProvider.updateNotificationSetting('notificationsEnabled', value);
          },
        ),
        const Divider(),
        if (settingsProvider.settings.notificationsEnabled) ...[
          SwitchListTile(
            title: const Text('Price Alerts'),
            subtitle: const Text('Get notified when prices change significantly'),
            value: settingsProvider.settings.priceAlertsEnabled,
            onChanged: (value) {
              settingsProvider.updateNotificationSetting('priceAlertsEnabled', value);
            },
          ),
          SwitchListTile(
            title: const Text('Market Updates'),
            subtitle: const Text('Receive updates about market trends and changes'),
            value: settingsProvider.settings.marketUpdatesEnabled,
            onChanged: (value) {
              settingsProvider.updateNotificationSetting('marketUpdatesEnabled', value);
            },
          ),
          SwitchListTile(
            title: const Text('Price Predictions'),
            subtitle: const Text('Get AI-powered predictions about future prices'),
            value: settingsProvider.settings.predictionAlertsEnabled,
            onChanged: (value) {
              settingsProvider.updateNotificationSetting('predictionAlertsEnabled', value);
            },
          ),
        ],
        const Divider(),
        ListTile(
          title: const Text('Manage Notifications'),
          subtitle: Text('${notificationProvider.unreadCount} unread notifications'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        if (notificationProvider.notifications.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications'),
                    content: const Text('Are you sure you want to delete all notifications?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          notificationProvider.clearAllNotifications(); // Fixed method name here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All notifications cleared')),
                          );
                        },
                        child: const Text('CLEAR ALL'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
              ),
              child: const Text('Clear All Notifications'),
            ),
          ),
      ],
    );
  }
}

