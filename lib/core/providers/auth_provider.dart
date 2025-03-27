import 'package:flutter/foundation.dart';
import '../../core/models/user.dart';
import '../../core/services/service_locator.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _userId;  // Added to store user ID

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;  // Getter for user ID

  // Initialize and check for stored user ID
  Future<void> init() async {
    final prefs = serviceLocator.preferences;
    final storedUserId = prefs.getString(AppConstants.prefUserId);
    
    if (storedUserId != null) {
      _userId = storedUserId;
      debugPrint("Stored user ID found: $_userId");
    }
    
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = serviceLocator.preferences;
      final token = prefs.getString(AppConstants.prefToken);
      final storedUserId = prefs.getString(AppConstants.prefUserId);

      debugPrint("Token found: $token");
      debugPrint("User ID found: $storedUserId");

      if (token != null && storedUserId != null) {
        _userId = storedUserId;
        _isAuthenticated = true;
        debugPrint("Fetching user profile using stored ID: $_userId");
        await getUserProfile();
        debugPrint("User profile fetched successfully.");
      } else {
        _isAuthenticated = false;
        _user = null;
        _userId = null;
        debugPrint("No token or user ID found, user is not authenticated.");
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
      final userData = await serviceLocator.apiService.register(name, email, password);
      
      // Store user data from response
      if (userData != null) {
        // Extract and store user ID
        final userId = userData['id'] ?? userData['_id'];
        if (userId != null) {
          _userId = userId.toString();
          final prefs = serviceLocator.preferences;
          await prefs.setString(AppConstants.prefUserId, _userId!);
          debugPrint("User ID stored after registration: $_userId");
        }
        
        _user = User(
          id: _userId,
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
        );
        _isAuthenticated = true;
      }
      
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
      // Update to handle the nested response structure
      final userData = await serviceLocator.apiService.login(email, password);
      
      // Store user data from response
      if (userData != null) {
        // Extract and store user ID
        final userId = userData['id'] ?? userData['_id'];
        if (userId != null) {
          _userId = userId.toString();
          final prefs = serviceLocator.preferences;
          await prefs.setString(AppConstants.prefUserId, _userId!);
          debugPrint("User ID stored after login: $_userId");
        }
        
        _user = User(
          id: _userId,
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
        );
        _isAuthenticated = true;
      } else {
        // If no user data is returned, fetch profile separately using stored ID
        _isAuthenticated = true;
        await getUserProfile();
      }
      
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
      debugPrint("Fetching user profile from API using ID: $_userId");
      
      // Only proceed if we have a user ID
      if (_userId == null) {
        debugPrint("Cannot fetch profile: User ID is null");
        return;
      }
      
      final user = await serviceLocator.apiService.getUserProfile(_userId!);
      
      if (user != null) {
        _user = user;
        // Add null check for user.name
        final userName = user.name ?? 'Unknown';
        debugPrint("User profile loaded: $userName");
      } else {
        debugPrint("User profile is null");
        _user = null;
      }
    } catch (e) {
      debugPrint("Failed to fetch user profile: $e");
      _user = null;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await serviceLocator.apiService.logout();
      _isAuthenticated = false;
      _user = null;
      
      final prefs = serviceLocator.preferences;
      await prefs.remove(AppConstants.prefToken);
      await prefs.remove(AppConstants.prefUserId);  // Also remove user ID
      _userId = null;
      
      debugPrint("User signed out and credentials removed.");
    } catch (e) {
      debugPrint("Sign out error: $e");
    }
    notifyListeners();
  }

  // Other methods remain the same...
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}