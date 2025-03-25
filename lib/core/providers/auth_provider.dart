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

      debugPrint("Token found: $token");

      if (token != null) {
        _isAuthenticated = true;
        debugPrint("Fetching user profile...");
        await getUserProfile();
        debugPrint("User profile fetched successfully.");
      } else {
        _isAuthenticated = false;
        _user = null;
        debugPrint("No token found, user is not authenticated.");
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      debugPrint("Error checking auth status: $e");
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
      debugPrint("Register error: $e");
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("Login error: $e");
      notifyListeners();
      return false;
    }
  }

  Future<void> getUserProfile() async {
    try {
      debugPrint("Fetching user profile from API...");
      final user = await serviceLocator.apiService.getUserProfile();
      _user = user;
      debugPrint("User profile loaded: ${user.name}");
    } catch (e) {
      debugPrint("Failed to fetch user profile: $e");
      _user = null;
    }
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await serviceLocator.apiService.forgotPassword(email);
      _isLoading = false;
      debugPrint("Forgot password email sent to: $email");
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("Forgot password error: $e");
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
      debugPrint("Password reset successful.");
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint("Reset password error: $e");
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await serviceLocator.apiService.logout();
      _isAuthenticated = false;
      _user = null;
      final prefs = serviceLocator.preferences;
      await prefs.remove('token');
      debugPrint("User signed out and token removed.");
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
