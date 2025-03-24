import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../services/service_locator.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  
  ThemeProvider(this._isDarkMode);
  
  bool get isDarkMode => _isDarkMode;
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    final prefs = serviceLocator.preferences;
    await prefs.setBool(AppConstants.prefThemeMode, _isDarkMode);
    
    notifyListeners();
  }
  
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    
    final prefs = serviceLocator.preferences;
    await prefs.setBool(AppConstants.prefThemeMode, _isDarkMode);
    
    notifyListeners();
  }
}

