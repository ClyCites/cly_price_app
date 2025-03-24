import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/service_locator.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> checkAuthStatus() async {
    try {
      final prefs = serviceLocator.preferences;
      final token = prefs.getString('token');
      
      if (token != null) {
        _isAuthenticated = true;
        await getUserProfile();
      } else {
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }
    
    notifyListeners();
  }
  
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await serviceLocator.apiService.register(name, email, password);
      _isAuthenticated = true;
      await getUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await serviceLocator.apiService.login(email, password);
      _isAuthenticated = true;
      await getUserProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> getUserProfile() async {
    try {
      final user = await serviceLocator.apiService.getUserProfile();
      _user = user;
      notifyListeners();
    } catch (e) {
      // If we can't get the profile, we should log out
      await signOut();
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await serviceLocator.apiService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> resetPassword(String token, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await serviceLocator.apiService.resetPassword(token, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    await serviceLocator.apiService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

