import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../models/price_alert_model.dart';
import '../models/notification_model.dart';
import '../services/service_locator.dart';
import '../utils/app_logger.dart';
import 'notification_provider.dart';

class PriceAlertProvider with ChangeNotifier {
  List<PriceAlert> _alerts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  // Getters
  List<PriceAlert> get alerts => _alerts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  // Initialize and load alerts
  Future<void> initialize() async {
    await loadAlerts();
  }

  // Load alerts from storage
  Future<void> loadAlerts() async {
    _setLoading(true);

    try {
      // Try to load from API
      final apiService = serviceLocator.apiService;
      final userId = await _getUserId();
      
      if (userId != null) {
        final alertsData = await apiService.getPriceAlerts(userId);
        _alerts = PriceAlert.fromJsonList(alertsData);
      } else {
        // If no user ID, load from local storage
        _alerts = await _loadAlertsFromStorage();
      }
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error loading alerts: $e');
      
      // If API fails, try to load from local storage
      try {
        _alerts = await _loadAlertsFromStorage();
        _setLoading(false);
        notifyListeners();
      } catch (storageError) {
        _setLoading(false);
        _setError(true, 'Failed to load alerts: $e');
        notifyListeners();
      }
    }
  }

  // Create a new alert
  Future<void> createAlert(PriceAlert alert) async {
    _setLoading(true);

    try {
      // Try to create in API
      final apiService = serviceLocator.apiService;
      final createdAlert = await apiService.createPriceAlert(alert);
      
      // Add to local list
      _alerts.add(createdAlert);
      
      // Save to local storage
      await _saveAlertsToStorage(_alerts);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error creating alert: $e');
      
      // In development or if API fails, still add to local list
      if (kDebugMode) {
        _alerts.add(alert);
        await _saveAlertsToStorage(_alerts);
        _setLoading(false);
        notifyListeners();
      } else {
        _setLoading(false);
        _setError(true, 'Failed to create alert: $e');
        notifyListeners();
        throw e; // Re-throw to handle in UI
      }
    }
  }

  // Update an existing alert
  Future<void> updateAlert(PriceAlert alert) async {
    _setLoading(true);

    try {
      // Try to update in API
      final apiService = serviceLocator.apiService;
      final updatedAlert = await apiService.updatePriceAlert(alert);
      
      // Update in local list
      final index = _alerts.indexWhere((a) => a.id == alert.id);
      if (index >= 0) {
        _alerts[index] = updatedAlert;
      }
      
      // Save to local storage
      await _saveAlertsToStorage(_alerts);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error updating alert: $e');
      
      // In development or if API fails, still update in local list
      if (kDebugMode) {
        final index = _alerts.indexWhere((a) => a.id == alert.id);
        if (index >= 0) {
          _alerts[index] = alert;
        }
        await _saveAlertsToStorage(_alerts);
        _setLoading(false);
        notifyListeners();
      } else {
        _setLoading(false);
        _setError(true, 'Failed to update alert: $e');
        notifyListeners();
        throw e; // Re-throw to handle in UI
      }
    }
  }

  // Delete an alert
  Future<void> deleteAlert(String id) async {
    _setLoading(true);

    try {
      // Try to delete from API
      final apiService = serviceLocator.apiService;
      await apiService.deletePriceAlert(id);
      
      // Remove from local list
      _alerts.removeWhere((alert) => alert.id == id);
      
      // Save to local storage
      await _saveAlertsToStorage(_alerts);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error deleting alert: $e');
      
      // In development or if API fails, still remove from local list
      if (kDebugMode) {
        _alerts.removeWhere((alert) => alert.id == id);
        await _saveAlertsToStorage(_alerts);
        _setLoading(false);
        notifyListeners();
      } else {
        _setLoading(false);
        _setError(true, 'Failed to delete alert: $e');
        notifyListeners();
        throw e; // Re-throw to handle in UI
      }
    }
  }

  // Toggle alert active status
  Future<void> toggleAlertStatus(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);
    if (index < 0) return;
    
    final alert = _alerts[index];
    final updatedAlert = alert.copyWith(isActive: !alert.isActive);
    
    await updateAlert(updatedAlert);
  }

  // Get alerts for a specific product
  List<PriceAlert> getAlertsForProduct(String productId) {
    return _alerts.where((alert) => alert.productId == productId).toList();
  }

  // Check if alerts should be triggered
  Future<void> checkAlerts(String productId, String marketId, double currentPrice) async {
    final productAlerts = _alerts.where((alert) => 
      alert.isActive && 
      alert.productId == productId && 
      (alert.marketId == null || alert.marketId == marketId) &&
      (!alert.hasBeenTriggered || alert.frequency == AlertFrequency.always)
    ).toList();
    
    if (productAlerts.isEmpty) return;
    
    final notificationProvider = serviceLocator.notificationProvider as NotificationProvider?;
    if (notificationProvider == null) return;
    
    for (final alert in productAlerts) {
      bool shouldTrigger = false;
      
      switch (alert.alertType) {
        case AlertType.below:
          shouldTrigger = currentPrice <= alert.targetPrice;
          break;
        case AlertType.above:
          shouldTrigger = currentPrice >= alert.targetPrice;
          break;
        case AlertType.change:
          // For change alerts, we would need historical data
          // This is a simplified implementation
          shouldTrigger = false;
          break;
      }
      
      if (shouldTrigger) {
        // Update alert status
        final updatedAlert = alert.copyWith(
          hasBeenTriggered: true,
          lastTriggeredAt: DateTime.now(),
        );
        
        await updateAlert(updatedAlert);
        
        // Create notification
        final marketText = alert.marketName != null ? ' in ${alert.marketName}' : '';
        final message = '${alert.productName} price is now ${currentPrice.toStringAsFixed(2)} UGX${marketText}';
        
        await notificationProvider.createNotification(
          title: 'Price Alert Triggered',
          message: message,
          type: NotificationType.priceAlert,
          data: {
            'productId': alert.productId,
            'productName': alert.productName,
            'marketId': alert.marketId,
            'marketName': alert.marketName,
            'currentPrice': currentPrice,
            'targetPrice': alert.targetPrice,
            'alertType': alert.alertType.index,
          },
        );
      }
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(bool hasError, String? message) {
    _hasError = hasError;
    _errorMessage = message;
    notifyListeners();
  }

  // Storage methods
  Future<List<PriceAlert>> _loadAlertsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = prefs.getStringList('price_alerts') ?? [];
      
      return alertsJson
          .map((alertStr) => PriceAlert.fromJson(jsonDecode(alertStr)))
          .toList();
    } catch (e) {
      serviceLocator.logger.e('Error loading alerts from storage: $e');
      return [];
    }
  }

  Future<void> _saveAlertsToStorage(List<PriceAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = alerts.map((alert) => jsonEncode(alert.toJson())).toList();
      await prefs.setStringList('price_alerts', alertsJson);
    } catch (e) {
      serviceLocator.logger.e('Error saving alerts to storage: $e');
    }
  }

  Future<String?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      return null;
    }
  }

  // Create a mock alert for testing
  PriceAlert createMockAlert({
    required String productId,
    required String productName,
    String? marketId,
    String? marketName,
    required double targetPrice,
    required AlertType alertType,
  }) {
    return PriceAlert(
      id: const Uuid().v4(),
      productId: productId,
      productName: productName,
      marketId: marketId,
      marketName: marketName,
      targetPrice: targetPrice,
      alertType: alertType,
      frequency: AlertFrequency.once,
      isActive: true,
      createdAt: DateTime.now(),
      userId: 'mock_user_id',
    );
  }
}

