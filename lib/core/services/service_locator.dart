import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../database/database_service.dart';
import '../utils/app_logger.dart';
import '../providers/notification_provider.dart';
import '../providers/price_alert_provider.dart';

// Global service locator
final serviceLocator = _ServiceLocator();

class _ServiceLocator {
  late SharedPreferences _preferences;
  late ApiService _apiService;
  late DatabaseService _databaseService;
  late Logger _logger;
  late NotificationProvider _notificationProvider;
  late PriceAlertProvider _priceAlertProvider;
  
  SharedPreferences get preferences => _preferences;
  ApiService get apiService => _apiService;
  DatabaseService get databaseService => _databaseService;
  Logger get logger => _logger;
  NotificationProvider get notificationProvider => _notificationProvider;
  PriceAlertProvider get priceAlertProvider => _priceAlertProvider;
}

Future<void> setupServiceLocator() async {
  // Initialize shared preferences
  serviceLocator._preferences = await SharedPreferences.getInstance();
  
  // Initialize logger
  serviceLocator._logger = AppLogger.instance;
  
  // Initialize database service
  serviceLocator._databaseService = DatabaseService();
  await serviceLocator._databaseService.initialize();
  
  // Initialize API service
  serviceLocator._apiService = ApiService();
  
  // Initialize providers
  serviceLocator._notificationProvider = NotificationProvider();
  serviceLocator._priceAlertProvider = PriceAlertProvider();
  
  // Initialize providers
  await serviceLocator._notificationProvider.initialize();
  await serviceLocator._priceAlertProvider.initialize();
}

