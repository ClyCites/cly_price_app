import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/models/user.dart';
import '../../core/services/service_locator.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  String? _userId;
  String? _profilePicture;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _userId;
  String? get profilePicture => _profilePicture;
  
  // Add unreadCount getter
  int get unreadCount => 0; // This will be implemented in NotificationProvider

  // Initialize and check for stored user ID and session
  Future<void> init() async {
    final prefs = serviceLocator.preferences;
    final storedUserId = prefs.getString(AppConstants.prefUserId);
    final storedProfilePicture = prefs.getString(AppConstants.prefUserProfilePicture);
    
    if (storedUserId != null) {
      _userId = storedUserId;
      _profilePicture = storedProfilePicture;
      debugPrint("Stored user ID found: $_userId");
    }
    
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = serviceLocator.preferences;
      final token = prefs.getString(AppConstants.prefToken);
      final storedUserId = prefs.getString(AppConstants.prefUserId);
      final tokenExpiry = prefs.getInt(AppConstants.prefTokenExpiry);

      debugPrint("Token found: $token");
      debugPrint("User ID found: $storedUserId");
      
      // Check if token exists and is not expired
      final bool isSessionValid = token != null && 
                                 storedUserId != null && 
                                 tokenExpiry != null && 
                                 DateTime.now().millisecondsSinceEpoch < tokenExpiry;

      if (isSessionValid) {
        _userId = storedUserId;
        _isAuthenticated = true;
        debugPrint("Session is valid, fetching user profile using stored ID: $_userId");
        await getUserProfile();
        debugPrint("User profile fetched successfully.");
      } else if (token != null && storedUserId != null) {
        // Token exists but might be expired, try to refresh
        debugPrint("Session may be expired, attempting to refresh");
        try {
          // You could implement token refresh logic here if your API supports it
          // For now, we'll just try to get the user profile
          await getUserProfile();
          _isAuthenticated = true;
          
          // Update token expiry
          await _updateSessionExpiry();
          
          debugPrint("Session refreshed successfully");
        } catch (e) {
          debugPrint("Failed to refresh session: $e");
          _isAuthenticated = false;
          _user = null;
          _userId = null;
          // Clear stored credentials
          await signOut();
        }
      } else {
        _isAuthenticated = false;
        _user = null;
        _userId = null;
        debugPrint("No valid session found, user is not authenticated.");
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      debugPrint("Error checking auth status: $e");
    }

    notifyListeners();
  }

  // Update session expiry time
  Future<void> _updateSessionExpiry() async {
    final prefs = serviceLocator.preferences;
    final expiryTime = DateTime.now().millisecondsSinceEpoch + AppConstants.sessionDuration;
    await prefs.setInt(AppConstants.prefTokenExpiry, expiryTime);
    debugPrint("Session expiry updated to: ${DateTime.fromMillisecondsSinceEpoch(expiryTime)}");
  }

  Future<bool> register(String name, String email, String password, {String? profilePicture}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await serviceLocator.apiService.register(
        name, 
        email, 
        password,
        profilePicture: profilePicture,
      );
      
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
        
        // Store profile picture if available
        final userProfilePicture = userData['profilePicture'];
        if (userProfilePicture != null) {
          _profilePicture = userProfilePicture;
          final prefs = serviceLocator.preferences;
          await prefs.setString(AppConstants.prefUserProfilePicture, userProfilePicture);
          debugPrint("Profile picture stored after registration");
        }
        
        _user = User(
          id: _userId,
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          profilePicture: userProfilePicture,
        );
        _isAuthenticated = true;
        
        // Set session expiry (7 days)
        await _updateSessionExpiry();
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
        
        // Store profile picture if available
        final userProfilePicture = userData['profilePicture'];
        if (userProfilePicture != null) {
          _profilePicture = userProfilePicture;
          final prefs = serviceLocator.preferences;
          await prefs.setString(AppConstants.prefUserProfilePicture, userProfilePicture);
          debugPrint("Profile picture stored after login");
        }
        
        _user = User(
          id: _userId,
          name: userData['name'],
          email: userData['email'],
          role: userData['role'] ?? 'user',
          profilePicture: userProfilePicture,
        );
        _isAuthenticated = true;
        
        // Set session expiry (7 days)
        await _updateSessionExpiry();
      } else {
        // If no user data is returned, fetch profile separately using stored ID
        _isAuthenticated = true;
        await getUserProfile();
        
        // Set session expiry (7 days)
        await _updateSessionExpiry();
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

  // Implement the forgotPassword method
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
      debugPrint("Forgot password error: $e");
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
        _profilePicture = user.profilePicture;
        
        // Add null check for user.name
        final userName = user.name ?? 'Unknown';
        debugPrint("User profile loaded: $userName");
        
        // Update stored profile data
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
        debugPrint("User profile is null");
        _user = null;
      }
    } catch (e) {
      debugPrint("Failed to fetch user profile: $e");
      _user = null;
    }
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_userId == null) {
        _error = "User ID not found";
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      final updatedUser = await serviceLocator.apiService.updateUserProfile(
        userId: _userId!,
        name: name,
        email: email,
        profilePicture: profilePicture,
      );
      
      if (updatedUser != null) {
        _user = updatedUser;
        _profilePicture = updatedUser.profilePicture;
        
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

  Future<void> signOut() async {
    try {
      await serviceLocator.apiService.logout();
      _isAuthenticated = false;
      _user = null;
      _profilePicture = null;
      
      final prefs = serviceLocator.preferences;
      await prefs.remove(AppConstants.prefToken);
      await prefs.remove(AppConstants.prefUserId);
      await prefs.remove(AppConstants.prefUserName);
      await prefs.remove(AppConstants.prefUserEmail);
      await prefs.remove(AppConstants.prefUserRole);
      await prefs.remove(AppConstants.prefUserProfilePicture);
      await prefs.remove(AppConstants.prefTokenExpiry);
      _userId = null;
      
      debugPrint("User signed out and credentials removed.");
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

