import 'package:flutter/foundation.dart';
import '../../core/models/user.dart';
import '../../core/services/service_locator.dart';
import '../../core/constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  
  // Get user ID from shared preferences
  Future<String?> getUserId() async {
    final prefs = serviceLocator.preferences;
    return prefs.getString(AppConstants.prefUserId);
  }

  // Initialize user data
  Future<void> initialize() async {
    final userId = await getUserId();
    if (userId != null) {
      await fetchUserProfile(userId);
    }
  }

  // Fetch user profile using ID
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("Fetching user profile for ID: $userId");
      final user = await serviceLocator.apiService.getUserProfile(userId);
      
      if (user != null) {
        _user = user;
        debugPrint("User profile loaded: ${user.name ?? 'Unknown'}");
        
        // Cache user data in preferences for offline access
        final prefs = serviceLocator.preferences;
        if (user.name != null) {
          await prefs.setString(AppConstants.prefUserName, user.name!);
        }
        if (user.email != null) {
          await prefs.setString(AppConstants.prefUserEmail, user.email!);
        }
        if (user.role != null) {
          await prefs.setString(AppConstants.prefUserRole, user.role!);
        }
        if (user.profilePicture != null) {
          await prefs.setString(AppConstants.prefUserProfilePicture, user.profilePicture!);
        }
      } else {
        debugPrint("Failed to load user profile");
        _error = "Could not load user profile";
        
        // Try to load from cached data
        await _loadUserFromCache();
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      _error = e.toString();
      
      // Try to load from cached data
      await _loadUserFromCache();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Load user from cached preferences
  Future<void> _loadUserFromCache() async {
    try {
      final prefs = serviceLocator.preferences;
      final userId = prefs.getString(AppConstants.prefUserId);
      final name = prefs.getString(AppConstants.prefUserName);
      final email = prefs.getString(AppConstants.prefUserEmail);
      final role = prefs.getString(AppConstants.prefUserRole);
      final profilePicture = prefs.getString(AppConstants.prefUserProfilePicture);
      
      if (userId != null) {
        _user = User(
          id: userId,
          name: name,
          email: email,
          role: role,
          profilePicture: profilePicture,
        );
        debugPrint("Loaded user from cache: ${_user?.name ?? 'Unknown'}");
      }
    } catch (e) {
      debugPrint("Error loading user from cache: $e");
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? bio,
    String? phoneNumber,
    String? location,
    String? profilePicture,
  }) async {
    final userId = await getUserId();
    if (userId == null) {
      _error = "User ID not found";
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final updatedUser = await serviceLocator.apiService.updateUserProfile(
        userId: userId,
        name: name,
        email: email,
        bio: bio,
        phoneNumber: phoneNumber,
        location: location,
        profilePicture: profilePicture,
      );
      
      if (updatedUser != null) {
        _user = updatedUser;
        
        // Update cached data
        final prefs = serviceLocator.preferences;
        if (updatedUser.name != null) {
          await prefs.setString(AppConstants.prefUserName, updatedUser.name!);
        }
        if (updatedUser.email != null) {
          await prefs.setString(AppConstants.prefUserEmail, updatedUser.email!);
        }
        if (updatedUser.profilePicture != null) {
          await prefs.setString(AppConstants.prefUserProfilePicture, updatedUser.profilePicture!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = "Failed to update profile";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final userId = await getUserId();
    if (userId == null) {
      return {};
    }
    
    try {
      return await serviceLocator.apiService.getUserPreferences(userId);
    } catch (e) {
      debugPrint("Error fetching user preferences: $e");
      return {};
    }
  }
  
  // Update user preferences
  Future<bool> updateUserPreferences(Map<String, dynamic> preferences) async {
    final userId = await getUserId();
    if (userId == null) {
      return false;
    }
    
    try {
      return await serviceLocator.apiService.updateUserPreferences(userId, preferences);
    } catch (e) {
      debugPrint("Error updating user preferences: $e");
      return false;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await serviceLocator.apiService.logout();
      clearUserData();
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }
  
  // Clear user data (called on logout)
  void clearUserData() {
    _user = null;
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

