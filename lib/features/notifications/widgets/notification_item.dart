import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/notification_provider.dart';

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  
  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final isRead = notification['isRead'] == true;
    
    return Card(
      margin: const EdgeInsets.all(8),
      color: isRead ? Colors.grey[200] : null,
      child: ListTile(
        leading: Icon(
          _getIconForType(notification['type']),
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          notification['message'],
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MMM d, yyyy').format(notification['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              DateFormat('h:mm a').format(notification['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            notificationProvider.markAsRead(notification['id']);
          }
        },
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    switch (type) {
      case 'price_alert':
        return Icons.attach_money;
      case 'market_insight':
        return Icons.insights;
      case 'app_update':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }
}

