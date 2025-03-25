import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;
  final bool priceAlertsEnabled; // Added direct property
  final bool marketUpdatesEnabled; // Added direct property
  final bool predictionAlertsEnabled; // Added direct property
  final bool systemNotificationsEnabled; // Added direct property
  final List<NotificationSetting> notificationSettings;
  final bool dataSync;
  final String currency;
  final MeasurementUnit measurementUnit;
  final bool analyticsEnabled;
  final DisplayPreferences displayPreferences;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = 'English',
    this.notificationsEnabled = true,
    this.priceAlertsEnabled = true, // Initialize direct property
    this.marketUpdatesEnabled = true, // Initialize direct property
    this.predictionAlertsEnabled = true, // Initialize direct property
    this.systemNotificationsEnabled = true, // Initialize direct property
    this.notificationSettings = const [],
    this.dataSync = true,
    this.currency = 'USD',
    this.measurementUnit = MeasurementUnit.metric,
    this.analyticsEnabled = true,
    this.displayPreferences = const DisplayPreferences(),
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    bool? priceAlertsEnabled, // Added to copyWith
    bool? marketUpdatesEnabled, // Added to copyWith
    bool? predictionAlertsEnabled, // Added to copyWith
    bool? systemNotificationsEnabled, // Added to copyWith
    List<NotificationSetting>? notificationSettings,
    bool? dataSync,
    String? currency,
    MeasurementUnit? measurementUnit,
    bool? analyticsEnabled,
    DisplayPreferences? displayPreferences,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled, // Added to copyWith
      marketUpdatesEnabled: marketUpdatesEnabled ?? this.marketUpdatesEnabled, // Added to copyWith
      predictionAlertsEnabled: predictionAlertsEnabled ?? this.predictionAlertsEnabled, // Added to copyWith
      systemNotificationsEnabled: systemNotificationsEnabled ?? this.systemNotificationsEnabled, // Added to copyWith
      notificationSettings: notificationSettings ?? this.notificationSettings,
      dataSync: dataSync ?? this.dataSync,
      currency: currency ?? this.currency,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      displayPreferences: displayPreferences ?? this.displayPreferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
      'priceAlertsEnabled': priceAlertsEnabled, // Added to toJson
      'marketUpdatesEnabled': marketUpdatesEnabled, // Added to toJson
      'predictionAlertsEnabled': predictionAlertsEnabled, // Added to toJson
      'systemNotificationsEnabled': systemNotificationsEnabled, // Added to toJson
      'notificationSettings': notificationSettings.map((e) => e.toJson()).toList(),
      'dataSync': dataSync,
      'currency': currency,
      'measurementUnit': measurementUnit.index,
      'analyticsEnabled': analyticsEnabled,
      'displayPreferences': displayPreferences.toJson(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      language: json['language'] ?? 'English',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      priceAlertsEnabled: json['priceAlertsEnabled'] ?? true, // Added to fromJson
      marketUpdatesEnabled: json['marketUpdatesEnabled'] ?? true, // Added to fromJson
      predictionAlertsEnabled: json['predictionAlertsEnabled'] ?? true, // Added to fromJson
      systemNotificationsEnabled: json['systemNotificationsEnabled'] ?? true, // Added to fromJson
      notificationSettings: (json['notificationSettings'] as List?)
          ?.map((e) => NotificationSetting.fromJson(e))
          .toList() ?? [],
      dataSync: json['dataSync'] ?? true,
      currency: json['currency'] ?? 'USD',
      measurementUnit: MeasurementUnit.values[json['measurementUnit'] ?? 0],
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      displayPreferences: json['displayPreferences'] != null
          ? DisplayPreferences.fromJson(json['displayPreferences'])
          : DisplayPreferences(),
    );
  }
}

class NotificationSetting {
  final String id;
  final String name;
  final bool enabled;
  final NotificationType type;

  const NotificationSetting({
    required this.id,
    required this.name,
    this.enabled = true,
    required this.type,
  });

  NotificationSetting copyWith({
    String? id,
    String? name,
    bool? enabled,
    NotificationType? type,
  }) {
    return NotificationSetting(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'enabled': enabled,
      'type': type.index,
    };
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    return NotificationSetting(
      id: json['id'],
      name: json['name'],
      enabled: json['enabled'] ?? true,
      type: NotificationType.values[json['type'] ?? 0],
    );
  }
}

enum NotificationType {
  priceAlert,
  marketUpdate,
  prediction,
  system,
}

enum MeasurementUnit {
  metric,
  imperial,
}

class DisplayPreferences {
  final bool showPriceHistory;
  final bool showPredictions;
  final bool showMarketComparisons;
  final ChartDisplayPeriod defaultChartPeriod;
  final int dataPointDensity;

  const DisplayPreferences({
    this.showPriceHistory = true,
    this.showPredictions = true,
    this.showMarketComparisons = true,
    this.defaultChartPeriod = ChartDisplayPeriod.month,
    this.dataPointDensity = 2, // 0: low, 1: medium, 2: high
  });

  DisplayPreferences copyWith({
    bool? showPriceHistory,
    bool? showPredictions,
    bool? showMarketComparisons,
    ChartDisplayPeriod? defaultChartPeriod,
    int? dataPointDensity,
  }) {
    return DisplayPreferences(
      showPriceHistory: showPriceHistory ?? this.showPriceHistory,
      showPredictions: showPredictions ?? this.showPredictions,
      showMarketComparisons: showMarketComparisons ?? this.showMarketComparisons,
      defaultChartPeriod: defaultChartPeriod ?? this.defaultChartPeriod,
      dataPointDensity: dataPointDensity ?? this.dataPointDensity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showPriceHistory': showPriceHistory,
      'showPredictions': showPredictions,
      'showMarketComparisons': showMarketComparisons,
      'defaultChartPeriod': defaultChartPeriod.index,
      'dataPointDensity': dataPointDensity,
    };
  }

  factory DisplayPreferences.fromJson(Map<String, dynamic> json) {
    return DisplayPreferences(
      showPriceHistory: json['showPriceHistory'] ?? true,
      showPredictions: json['showPredictions'] ?? true,
      showMarketComparisons: json['showMarketComparisons'] ?? true,
      defaultChartPeriod: ChartDisplayPeriod.values[json['defaultChartPeriod'] ?? 2],
      dataPointDensity: json['dataPointDensity'] ?? 2,
    );
  }
}

enum ChartDisplayPeriod {
  day,
  week,
  month,
  quarter,
  year,
  all,
}

