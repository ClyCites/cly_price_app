import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import '../models/notification_model.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider with ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  
  // Store recent notifications in memory
  final List<NotificationModel> _notifications = [];
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  // Get count of unread notifications
  int get unreadCount => _notifications.where((notification) => !notification.isRead).length;

  NotificationProvider() {
    // Constructor is kept empty, initialization is done explicitly via initialize()
  }

  /// Initializes the notification service
  /// Sets up notification channels and requests permissions
  Future<void> initialize() async {
    try {
      _setLoading(true);
      
      // Initialize timezone data for scheduled notifications
      tz.initializeTimeZones();
      
      // Initialize notification settings for different platforms
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
          
      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
          // Handle iOS foreground notification
        },
      );
      
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      
      // Initialize the plugin
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Handle notification tap
          if (response.payload != null) {
            debugPrint('Notification payload: ${response.payload}');
            // Parse the payload and handle navigation
            _handleNotificationTap(response.payload!);
          }
        },
      );
      
      // Request permissions for iOS
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          
      // Create notification channels for Android
      await _createNotificationChannels();
      
      // Load saved notifications
      await loadNotifications();
      
      _isInitialized = true;
      _setLoading(false);
      _setError(null);
      
      debugPrint('NotificationProvider initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      _isInitialized = false;
      _setLoading(false);
      _setError('Failed to initialize notifications: $e');
    }
  }

  /// Load notifications from storage
  Future<void> loadNotifications() async {
    try {
      _setLoading(true);
      
      // Clear current notifications
      _notifications.clear();
      
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      // Parse notifications
      for (final json in notificationsJson) {
        try {
          final Map<String, dynamic> data = jsonDecode(json);
          final notification = NotificationModel.fromJson(data);
          _notifications.add(notification);
        } catch (e) {
          debugPrint('Error parsing notification: $e');
        }
      }
      
      // Sort notifications by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _setLoading(false);
      _setError(null);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _setLoading(false);
      _setError('Failed to load notifications: $e');
      notifyListeners();
    }
  }

  /// Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = _notifications
          .map((notification) => jsonEncode(notification.toJson()))
          .toList();
      await prefs.setStringList('notifications', notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
      _setError('Failed to save notifications: $e');
    }
  }

  /// Add a notification to the list
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.add(notification);
    notifyListeners();
    await _saveNotifications();
  }

  /// Remove a notification from the list
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    notifyListeners();
    await _saveNotifications();
    await cancelAllNotifications();
  }

  /// Creates a notification with the given details
  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      debugPrint('Notification provider not initialized');
      return;
    }
    
    // Generate a unique ID
    final String notificationId = const Uuid().v4();
    final int numericId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    // Create notification model
    final notification = NotificationModel(
      id: notificationId,
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      data: data,
    );
    
    // Add to in-memory list
    await addNotification(notification);
    
    // Convert data to JSON string for payload
    final String payload = jsonEncode(notification.toJson());
    
    // Determine channel based on notification type
    String channelId;
    switch (type) {
      case NotificationType.priceAlert:
        channelId = 'price_alerts_channel';
        break;
      case NotificationType.marketUpdate:
        channelId = 'market_updates_channel';
        break;
      case NotificationType.prediction:
        channelId = 'predictions_channel';
        break;
      case NotificationType.system:
      default:
        channelId = 'system_channel';
        break;
    }
    
    // Show the notification
    await showNotification(
      id: numericId,
      title: title,
      body: message,
      payload: payload,
      channelId: channelId,
    );
    
    // Log notification creation
    debugPrint('Created notification: $title - $message');
  }

  /// Creates notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidPlugin != null) {
      // Create price alerts channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'price_alerts_channel',
          'Price Alerts',
          description: 'Notifications for price alerts',
          importance: Importance.high,
        ),
      );
      
      // Create market updates channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'market_updates_channel',
          'Market Updates',
          description: 'Updates about market prices and trends',
          importance: Importance.defaultImportance,
        ),
      );
      
      // Create predictions channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'predictions_channel',
          'Price Predictions',
          description: 'Notifications about price predictions',
          importance: Importance.defaultImportance,
        ),
      );
      
      // Create system channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'system_channel',
          'System Notifications',
          description: 'System and app notifications',
          importance: Importance.low,
        ),
      );
    }
  }

  /// Shows an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'system_channel',
  }) async {
    if (!_isInitialized) {
      debugPrint('Notification provider not initialized');
      return;
    }

    // Determine importance based on channel
    Importance importance;
    Priority priority;
    
    switch (channelId) {
      case 'price_alerts_channel':
        importance = Importance.high;
        priority = Priority.high;
        break;
      case 'market_updates_channel':
      case 'predictions_channel':
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case 'system_channel':
      default:
        importance = Importance.low;
        priority = Priority.low;
        break;
    }

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Schedules a notification for a future time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationType type,
    Map<String, dynamic>? data,
    String? channelId,
  }) async {
    if (!_isInitialized) {
      debugPrint('Notification provider not initialized');
      return;
    }
    
    // Generate a unique ID
    final String notificationId = const Uuid().v4();
    
    // Create notification model
    final notification = NotificationModel(
      id: notificationId,
      title: title,
      message: body,
      type: type,
      timestamp: scheduledDate,
      data: data,
    );
    
    // Add to notifications list
    await addNotification(notification);
    
    // Convert data to JSON string for payload
    final String payload = jsonEncode(notification.toJson());
    
    // Determine channel based on notification type if not provided
    if (channelId == null) {
      switch (type) {
        case NotificationType.priceAlert:
          channelId = 'price_alerts_channel';
          break;
        case NotificationType.marketUpdate:
          channelId = 'market_updates_channel';
          break;
        case NotificationType.prediction:
          channelId = 'predictions_channel';
          break;
        case NotificationType.system:
        default:
          channelId = 'system_channel';
          break;
      }
    }

    // Determine importance based on channel
    Importance importance;
    Priority priority;
    
    switch (channelId) {
      case 'price_alerts_channel':
        importance = Importance.high;
        priority = Priority.high;
        break;
      case 'market_updates_channel':
      case 'predictions_channel':
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case 'system_channel':
      default:
        importance = Importance.low;
        priority = Priority.low;
        break;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _getChannelName(channelId),
          importance: importance,
          priority: priority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// Marks a notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(isRead: true);
      notifyListeners();
      await _saveNotifications();
    }
  }

  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    await _saveNotifications();
  }

  /// Cancels a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Handles notification tap
  void _handleNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload);
      final notification = NotificationModel.fromJson(data);
      
      // Mark as read
      markAsRead(notification.id);
      
      // Handle navigation based on notification type
      // This would typically be handled by a navigation service
      debugPrint('Handling notification tap: ${notification.type}');
      
      // Example of how to handle different notification types
      if (notification.type == NotificationType.priceAlert) {
        // Navigate to product details
        if (notification.data != null && notification.data!.containsKey('productId')) {
          final productId = notification.data!['productId'];
          debugPrint('Navigate to product: $productId');
          // navigationService.navigateTo('/product/$productId');
        }
      } else if (notification.type == NotificationType.marketUpdate) {
        // Navigate to market details
        if (notification.data != null && notification.data!.containsKey('marketId')) {
          final marketId = notification.data!['marketId'];
          debugPrint('Navigate to market: $marketId');
          // navigationService.navigateTo('/market/$marketId');
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  /// Gets channel name from channel ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'price_alerts_channel':
        return 'Price Alerts';
      case 'market_updates_channel':
        return 'Market Updates';
      case 'predictions_channel':
        return 'Price Predictions';
      case 'system_channel':
        return 'System Notifications';
      default:
        return 'Notifications';
    }
  }
  
  /// Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  /// Helper method to set error state
  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}

