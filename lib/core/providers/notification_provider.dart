import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/service_locator.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  
  NotificationProvider() {
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    // In a real app, you would fetch notifications from an API
    // For now, we'll use some dummy data
    _notifications = [
      {
        'id': '1',
        'title': 'Price Alert',
        'message': 'Rice prices have increased by 5% in Kampala Central Market',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'type': 'price_alert',
        'data': {
          'product': 'Rice',
          'market': 'Kampala Central Market',
          'price': 2500,
          'change': 5,
        },
      },
      {
        'id': '2',
        'title': 'Market Insight',
        'message': 'Best time to sell Maize is approaching based on historical data',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': false,
        'type': 'market_insight',
        'data': {
          'product': 'Maize',
        },
      },
      {
        'id': '3',
        'title': 'New Feature',
        'message': 'You can now compare prices across different markets',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'isRead': true,
        'type': 'app_update',
        'data': {},
      },
    ];
    
    _calculateUnreadCount();
    notifyListeners();
  }
  
  void _calculateUnreadCount() {
    _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
  }
  
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _calculateUnreadCount();
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i]['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();
  }
  
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _calculateUnreadCount();
    notifyListeners();
  }
  
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
    _calculateUnreadCount();
    notifyListeners();
  }
  
  void clearAll() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}

