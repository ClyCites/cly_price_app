class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.clycites.com/v1';
  
  // Database
  static const String dbName = 'clycites_db';
  static const int dbVersion = 1;
  
  // Tables
  static const String productsTable = 'products';
  static const String priceDataTable = 'price_data';
  static const String priceEntriesTable = 'price_entries';
  static const String trendingProductsTable = 'trending_products';
  
  // Preferences
  static const String prefThemeMode = 'theme_mode';
  static const String prefLastSync = 'last_sync';
  
  // Notifications
  static const String notificationChannelId = 'clycites_channel';
  static const String notificationChannelName = 'ClyCites Notifications';
  static const String notificationChannelDesc = 'Notifications from ClyCites app';
}

