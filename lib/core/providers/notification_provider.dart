import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
  // Load notifications from local storage
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      _notifications = notificationsJson
          .map((json) => NotificationModel.fromJson(jsonDecode(json)))
          .toList();
      
      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save notifications to local storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      _error = 'Failed to save notifications: ${e.toString()}';
      notifyListeners();
    }
  }

  // Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
    await _saveNotifications();
  }

  // Create and add a new notification
  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );
    
    await addNotification(notification);
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await _saveNotifications();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _saveNotifications();
  }

  // Remove a notification
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveNotifications();
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications = [];
    notifyListeners();
    await _saveNotifications();
  }

  // Add sample notifications for testing
  Future<void> addSampleNotifications() async {
    final now = DateTime.now();
    
    final notifications = [
      NotificationModel(
        id: '1',
        title: 'Price Alert: Maize',
        message: 'Maize prices have increased by 5% in the last 24 hours.',
        type: NotificationType.priceAlert,
        timestamp: now.subtract(const Duration(minutes: 30)),
        data: {'productId': 'maize-001', 'priceChange': 5.0},
      ),
      NotificationModel(
        id: '2',
        title: 'Market Update',
        message: 'New market data available for Nairobi region.',
        type: NotificationType.marketUpdate,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: '3',
        title: 'Price Prediction',
        message: 'Our AI predicts rice prices will decrease next week.',
        type: NotificationType.prediction,
        timestamp: now.subtract(const Duration(hours: 5)),
        data: {'productId': 'rice-001', 'predictionChange': -3.2},
      ),
      NotificationModel(
        id: '4',
        title: 'Welcome to ClyCites',
        message: 'Thank you for installing our app! Start tracking agricultural prices now.',
        type: NotificationType.system,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
    
    _notifications = notifications;
    notifyListeners();
    await _saveNotifications();
  }
}

