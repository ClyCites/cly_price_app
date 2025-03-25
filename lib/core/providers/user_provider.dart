import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  UserProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      final userRole = prefs.getString('user_role');
      final userProfilePic = prefs.getString('user_profile_pic');

      if (userId != null && userName != null && userEmail != null) {
        _currentUser = User(
          id: userId,
          name: userName,
          email: userEmail,
          role: userRole ?? 'farmer',
          permissions: [], // Add appropriate default value
          isActive: true, // Add appropriate default value
          createdAt: DateTime.now(), // Add appropriate default value
          updatedAt: DateTime.now(), // Add appropriate default value
        );
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load user data: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, you would make an API call here
      // This is a mock implementation for demonstration
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      
      // Mock successful login for demo purposes
      if (email.isNotEmpty && password.isNotEmpty) {
        _currentUser = User(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@')[0],
          email: email,
          role: 'farmer',
          permissions: [], // Add appropriate default value
          isActive: true, // Add appropriate default value
          createdAt: DateTime.now(), // Add appropriate default value
          updatedAt: DateTime.now(), // Add appropriate default value
        );
        
        // Save user data to local storage
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_id', _currentUser!.id);
        prefs.setString('user_name', _currentUser!.name);
        prefs.setString('user_email', _currentUser!.email);
        prefs.setString('user_role', _currentUser!.role);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear user data from local storage
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('user_id');
      prefs.remove('user_name');
      prefs.remove('user_email');
      prefs.remove('user_role');
      prefs.remove('user_profile_pic');

      _currentUser = null;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? profilePicture,
  }) async {
    if (_currentUser == null) {
      _error = 'No user is logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, you would make an API call here
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      // Update user data
      _currentUser = User(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        role: _currentUser!.role,
        permissions: _currentUser!.permissions,
        isActive: _currentUser!.isActive,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      // Save updated user data to local storage
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user_name', _currentUser!.name);
      if (email != null) prefs.setString('user_email', _currentUser!.email);
      if (profilePicture != null) prefs.setString('user_profile_pic', profilePicture);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

