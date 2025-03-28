class AppConstants {
  // API
  static const String apiBaseUrl = 'https://clyapi.onrender.com/api';
  
  // Database
  static const String dbName = 'clycites_db';
  static const int dbVersion = 1;
  
  // Tables
  static const String productsTable = 'products';
  static const String priceDataTable = 'price_data';
  static const String priceEntriesTable = 'price_entries';
  static const String trendingProductsTable = 'trending_products';
  static const String marketsTable = 'markets';
  
  // Preferences
  static const String prefThemeMode = 'theme_mode';
  static const String prefLastSync = 'last_sync';
  static const String prefToken = 'auth_token';
  static const String prefUserId = 'user_id';
  static const String prefUserName = 'user_name';
  static const String prefUserEmail = 'user_email';
  static const String prefUserRole = 'user_role';
  static const String prefUserProfilePicture = 'user_profile_picture';
  static const String prefTokenExpiry = 'token_expiry';
  
  // Notifications
  static const String notificationChannelId = 'clycites_channel';
  static const String notificationChannelName = 'ClyCites Notifications';
  static const String notificationChannelDesc = 'Notifications from ClyCites app';
  
  // Product Categories
  static const List<String> productCategories = [
    'grain',
    'vegetable',
    'fruit',
    'meat',
    'beverage',
  ];
  
  // Product Types
  static const List<String> productTypes = [
    'solid',
    'liquid',
  ];
  
  // Units
  static const Map<String, List<String>> productTypeUnits = {
    'solid': ['kg', 'g', 'ton'],
    'liquid': ['liters', 'ml'],
  };
  
  // Timeframes
  static const List<String> timeframes = [
    'Day',
    'Week',
    'Month',
    '3 Months',
    'Year',
  ];
  
  // Prediction Timeframes
  static const List<String> predictionTimeframes = [
    'Week',
    'Month',
    '3 Months',
    '6 Months',
    'Year',
  ];

  // Session Duration (7 days in milliseconds)
  static const int sessionDuration = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
}

