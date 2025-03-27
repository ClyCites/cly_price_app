import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification_model.dart';
import '../common/widgets/empty_state.dart';
import '../common/widgets/loading_indicator.dart';
import '../common/widgets/error_view.dart';
import 'widgets/notification_item.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () {
                    provider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All notifications marked as read')),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.notifications.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Clear all notifications',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Notifications'),
                        content: const Text('Are you sure you want to delete all notifications?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              provider.clearAll(); // Fixed method name here
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }
          
          if (provider.error != null) {
            return ErrorView(
              message: provider.error!,
              onRetry: () => provider.loadNotifications(),
            );
          }
          
          if (provider.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off,
              title: 'No Notifications',
              message: 'You don\'t have any notifications yet. Check back later!',
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.loadNotifications(),
            child: ListView.builder(
              itemCount: provider.notifications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    provider.removeNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification removed'),
                        action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () => provider.addNotification(notification),
                        ),
                      ),
                    );
                  },
                  child: NotificationItem(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        provider.markAsRead(notification.id);
                      }
                      // Handle notification tap based on type
                      _handleNotificationTap(notification);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  void _handleNotificationTap(NotificationModel notification) {
    // Navigate to different screens based on notification type
    switch (notification.type) {
      case NotificationType.priceAlert:
        // Navigate to product details or price screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to price details for ${notification.title}')),
        );
        break;
      case NotificationType.marketUpdate:
        // Navigate to markets screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to market updates')),
        );
        break;
      case NotificationType.prediction:
        // Navigate to predictions screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to price predictions')),
        );
        break;
      case NotificationType.system:
        // Just mark as read, no navigation
        break;
    }
  }
}

