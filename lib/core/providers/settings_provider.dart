import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsProvider with ChangeNotifier {
  AppSettings _settings = AppSettings(
    notificationSettings: [
      NotificationSetting(
        id: 'price_alerts',
        name: 'Price Alerts',
        type: NotificationType.priceAlert,
      ),
      NotificationSetting(
        id: 'market_updates',
        name: 'Market Updates',
        type: NotificationType.marketUpdate,
      ),
      NotificationSetting(
        id: 'predictions',
        name: 'Prediction Notifications',
        type: NotificationType.prediction,
      ),
      NotificationSetting(
        id: 'system',
        name: 'System Notifications',
        type: NotificationType.system,
      ),
    ],
    priceAlertsEnabled: true,
    marketUpdatesEnabled: true,
    predictionAlertsEnabled: true,
    systemNotificationsEnabled: true,
  );
  bool _isLoading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');

      if (settingsJson != null) {
        final Map<String, dynamic> decodedSettings = jsonDecode(settingsJson);
        _settings = AppSettings.fromJson(decodedSettings);
      } else {
        // Initialize with default settings if none exist
        _settings = AppSettings(
          notificationSettings: [
            NotificationSetting(
              id: 'price_alerts',
              name: 'Price Alerts',
              type: NotificationType.priceAlert,
            ),
            NotificationSetting(
              id: 'market_updates',
              name: 'Market Updates',
              type: NotificationType.marketUpdate,
            ),
            NotificationSetting(
              id: 'predictions',
              name: 'Prediction Notifications',
              type: NotificationType.prediction,
            ),
            NotificationSetting(
              id: 'system',
              name: 'System Notifications',
              type: NotificationType.system,
            ),
          ],
          priceAlertsEnabled: true,
          marketUpdatesEnabled: true,
          predictionAlertsEnabled: true,
          systemNotificationsEnabled: true,
        );
        await saveSettings();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString('app_settings', settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void updateThemeMode(ThemeMode themeMode) {
    _settings = _settings.copyWith(themeMode: themeMode);
    saveSettings();
    notifyListeners();
  }

  void updateLanguage(String language) {
    _settings = _settings.copyWith(language: language);
    saveSettings();
    notifyListeners();
  }

  void updateNotificationsEnabled(bool enabled) {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updatePriceAlertsEnabled(bool enabled) {
    _settings = _settings.copyWith(priceAlertsEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updateMarketUpdatesEnabled(bool enabled) {
    _settings = _settings.copyWith(marketUpdatesEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updatePredictionAlertsEnabled(bool enabled) {
    _settings = _settings.copyWith(predictionAlertsEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updateSystemNotificationsEnabled(bool enabled) {
    _settings = _settings.copyWith(systemNotificationsEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updateNotificationSetting(String id, bool enabled) {
    final updatedSettings = _settings.notificationSettings.map((setting) {
      if (setting.id == id) {
        return setting.copyWith(enabled: enabled);
      }
      return setting;
    }).toList();

    _settings = _settings.copyWith(notificationSettings: updatedSettings);
    
    // Also update the direct properties based on the ID
    if (id == 'price_alerts') {
      _settings = _settings.copyWith(priceAlertsEnabled: enabled);
    } else if (id == 'market_updates') {
      _settings = _settings.copyWith(marketUpdatesEnabled: enabled);
    } else if (id == 'predictions') {
      _settings = _settings.copyWith(predictionAlertsEnabled: enabled);
    } else if (id == 'system') {
      _settings = _settings.copyWith(systemNotificationsEnabled: enabled);
    }
    
    saveSettings();
    notifyListeners();
  }

  void updateDataSync(bool enabled) {
    _settings = _settings.copyWith(dataSync: enabled);
    saveSettings();
    notifyListeners();
  }

  void updateCurrency(String currency) {
    _settings = _settings.copyWith(currency: currency);
    saveSettings();
    notifyListeners();
  }

  void updateMeasurementUnit(MeasurementUnit unit) {
    _settings = _settings.copyWith(measurementUnit: unit);
    saveSettings();
    notifyListeners();
  }

  void updateAnalyticsEnabled(bool enabled) {
    _settings = _settings.copyWith(analyticsEnabled: enabled);
    saveSettings();
    notifyListeners();
  }

  void updateDisplayPreferences(DisplayPreferences preferences) {
    _settings = _settings.copyWith(displayPreferences: preferences);
    saveSettings();
    notifyListeners();
  }

  void updateChartPeriod(ChartDisplayPeriod period) {
    final updatedPreferences = _settings.displayPreferences.copyWith(
      defaultChartPeriod: period,
    );
    _settings = _settings.copyWith(displayPreferences: updatedPreferences);
    saveSettings();
    notifyListeners();
  }

  void updateDataPointDensity(int density) {
    final updatedPreferences = _settings.displayPreferences.copyWith(
      dataPointDensity: density,
    );
    _settings = _settings.copyWith(displayPreferences: updatedPreferences);
    saveSettings();
    notifyListeners();
  }

  void resetSettings() {
    _settings = AppSettings(
      notificationSettings: [
        NotificationSetting(
          id: 'price_alerts',
          name: 'Price Alerts',
          type: NotificationType.priceAlert,
        ),
        NotificationSetting(
          id: 'market_updates',
          name: 'Market Updates',
          type: NotificationType.marketUpdate,
        ),
        NotificationSetting(
          id: 'predictions',
          name: 'Prediction Notifications',
          type: NotificationType.prediction,
        ),
        NotificationSetting(
          id: 'system',
          name: 'System Notifications',
          type: NotificationType.system,
        ),
      ],
      priceAlertsEnabled: true,
      marketUpdatesEnabled: true,
      predictionAlertsEnabled: true,
      systemNotificationsEnabled: true,
    );
    saveSettings();
    notifyListeners();
  }
}

