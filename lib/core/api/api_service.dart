import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../models/user.dart'; // Adjust the path as necessary
import '../models/product.dart'; // Adjust the path as necessary
import '../models/price_data.dart'; // Adjust the path as necessary
import '../models/price_entry.dart'; // Adjust the path as necessary
import '../services/service_locator.dart';
import '../models/market_model.dart'; // Adjust the path as necessary
import '../models/price_alert_model.dart'; // Adjust the path as necessary
import '../utils/app_logger.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final logger = serviceLocator.logger;
  
  // Helper method to get auth token
  Future<String?> _getToken() async {
    final prefs = serviceLocator.preferences;
    return prefs.getString(AppConstants.prefToken);
  }
  
  // Helper method to create headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Generic GET request handler
  Future<dynamic> _get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      logger.e('GET request failed: $endpoint', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Generic POST request handler
  Future<dynamic> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      logger.e('POST request failed: $endpoint', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Generic PUT request handler
  Future<dynamic> _put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      logger.e('PUT request failed: $endpoint', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Generic DELETE request handler
  Future<dynamic> _delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      logger.e('DELETE request failed: $endpoint', error: e);
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  // Response handler
  dynamic _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      logger.e('API Error: ${response.statusCode}', error: data['message']);
      throw Exception(data['message'] ?? 'Request failed with status: ${response.statusCode}');
    }
  }
  
  // ==================
  // Auth API Methods
  // ==================
  
  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        // Store token
        final prefs = serviceLocator.preferences;
        final token = responseData['token'];
        if (token != null) {
          await prefs.setString(AppConstants.prefToken, token);
        }
        
        // Store user ID from registration response
        final userData = responseData['user'] ?? responseData;
        final userId = userData['_id'] ?? userData['id'];
        if (userId != null) {
          await prefs.setString(AppConstants.prefUserId, userId.toString());
          logger.d('User ID stored from registration: $userId');
        }
        
        // Return user data
        return userData;
      } else {
        throw responseData['message'] ?? 'Registration failed';
      }
    } catch (e) {
      logger.e('Register error: $e');
      throw e.toString();
    }
  }
  
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      logger.d('Login response: $responseData');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Handle nested response structure
        final userData = responseData['data'];
        if (userData != null) {
          // Store token
          final prefs = serviceLocator.preferences;
          final token = userData['token'];
          if (token != null) {
            await prefs.setString(AppConstants.prefToken, token);
            logger.d('Token stored: $token');
          } else {
            throw 'Token is missing from response';
          }
          
          // Store user ID - this is critical for subsequent API calls
          final userId = userData['id'] ?? userData['_id'];
          if (userId != null) {
            await prefs.setString(AppConstants.prefUserId, userId.toString());
            logger.d('User ID stored: $userId');
          } else {
            throw 'User ID is missing from response';
          }
          
          // Store other user data
          if (userData['name'] != null) {
            await prefs.setString(AppConstants.prefUserName, userData['name']);
          }
          if (userData['email'] != null) {
            await prefs.setString(AppConstants.prefUserEmail, userData['email']);
          }
          if (userData['role'] != null) {
            await prefs.setString(AppConstants.prefUserRole, userData['role']);
          }
          
          return userData;
        } else {
          throw 'User data is missing from response';
        }
      } else {
        throw responseData['message'] ?? 'Login failed';
      }
    } catch (e) {
      logger.e('Login error: $e');
      throw e.toString();
    }
  }
  
  Future<void> forgotPassword(String email) async {
    await _post('auth/forgot-password', {
      'email': email,
    });
  }
  
  Future<void> resetPassword(String token, String password) async {
    await _post('auth/reset-password/$token', {
      'password': password,
    });
  }
  
  Future<User?> getUserProfile(String userId) async {
    try {
      final headers = await _getHeaders();
      
      // Use the user ID in the API call
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/$userId'),
        headers: headers,
      );

      logger.d('Get profile response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        logger.d('Profile data: $responseData');
        
        // Check if response has the expected structure
        if (responseData is Map<String, dynamic>) {
          return User.fromJson(responseData);
        } else {
          logger.w('Unexpected response format: $responseData');
          return null;
        }
      } else {
        logger.e('Failed to get user profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Get user profile error: $e');
      return null;
    }
  }
  
  Future<void> logout() async {
    final prefs = serviceLocator.preferences;
    await prefs.remove(AppConstants.prefToken);
    await prefs.remove(AppConstants.prefUserId);
  }
  
  // ==================
  // Price API Methods
  // ==================
  
  Future<List<Product>> getProducts() async {
    final data = await _get('products');
    return List<Product>.from(data.map((json) => Product.fromJson(json)));
  }
  
  Future<List<PriceData>> getPriceData(String product, String timeframe) async {
    final data = await _get('prices?product=$product&timeframe=$timeframe');
    return List<PriceData>.from(data.map((json) => PriceData.fromJson(json)));
  }
  
  Future<List<Product>> getTrendingProducts() async {
    final data = await _get('prices/trends/popular');
    return List<Product>.from(data.map((json) => Product.fromJson(json)));
  }
  
  Future<PriceEntry> submitPriceEntry(PriceEntry entry) async {
    final data = await _post('prices', entry.toJson());
    return PriceEntry.fromJson(data);
  }
  
  Future<Map<String, dynamic>> predictPrice(String product, String market, String timeframe) async {
    final data = await _post('prices/predict', {
      'product': product,
      'market': market,
      'timeframe': timeframe,
    });
    return data;
  }
  
  Future<List<Map<String, dynamic>>> getPriceTrends(String product, String market) async {
    final data = await _get('prices/trends/$product/$market');
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<Map<String, dynamic>>> compareMarketPrices(String product) async {
    final data = await _get('prices/compare?product=$product');
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<PriceData>> getHistoricalPrices(String product, String market) async {
    final data = await _get('prices/history/$product/$market');
    return List<PriceData>.from(data.map((json) => PriceData.fromJson(json)));
  }
  
  Future<void> setUserPriceAlert(String product, String market, double threshold) async {
    await _post('prices/alerts/set', {
      'product': product,
      'market': market,
      'alertThreshold': threshold,
    });
  }
  
  Future<List<Map<String, dynamic>>> getAveragePricePerMarket(String product) async {
    final data = await _get('prices/average/$product');
    return List<Map<String, dynamic>>.from(data);
  }
  
  Future<List<String>> getMarkets() async {
    final data = await _get('markets');
    return List<String>.from(data.map((json) => json['name']));
  }

  Future<Market> createMarket(Market market) async {
    try {
      final data = await _post('markets', market.toJson());
      return Market.fromJson(data);
    } catch (e) {
      logger.e('Create market failed', error: e);
      throw Exception('Failed to create market: ${e.toString()}');
    }
  }

  Future<void> deleteMarket(String id) async {
    try {
      await _delete('markets/$id');
    } catch (e) {
      logger.e('Delete market failed', error: e);
      throw Exception('Failed to delete market: ${e.toString()}');
    }
  }

  Future<Market> getMarketById(String id) async {
    try {
      final data = await _get('markets/$id');
      return Market.fromJson(data);
    } catch (e) {
      logger.e('Get market failed', error: e);
      throw Exception('Failed to get market: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getPriceAlerts(String userId) async {
    try {
      final data = await _get('prices/alerts?userId=$userId');
      return data;
    } catch (e) {
      logger.e('Get price alerts failed', error: e);
      throw Exception('Failed to get price alerts: ${e.toString()}');
    }
  }

  Future<PriceAlert> createPriceAlert(PriceAlert alert) async {
    try {
      final data = await _post('prices/alerts', alert.toJson());
      return PriceAlert.fromJson(data);
    } catch (e) {
      logger.e('Create price alert failed', error: e);
      throw Exception('Failed to create price alert: ${e.toString()}');
    }
  }

  Future<PriceAlert> updatePriceAlert(PriceAlert alert) async {
    try {
      final data = await _put('prices/alerts/${alert.id}', alert.toJson());
      return PriceAlert.fromJson(data);
    } catch (e) {
      logger.e('Update price alert failed', error: e);
      throw Exception('Failed to update price alert: ${e.toString()}');
    }
  }

  Future<void> deletePriceAlert(String id) async {
    try {
      await _delete('prices/alerts/$id');
    } catch (e) {
      logger.e('Delete price alert failed', error: e);
      throw Exception('Failed to delete price alert: ${e.toString()}');
    }
  }

  Future<User?> updateUserProfile({
  required String userId,
  String? name,
  String? email,
  String? bio,
  String? phoneNumber,
  String? location,
}) async {
  try {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (bio != null) 'bio': bio,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (location != null) 'location': location,
      }),
    );
    
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return User.fromJson(responseData);
    } else {
      logger.e('Failed to update user profile: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    logger.e('Update user profile error: $e');
    return null;
  }
}

// Get user preferences
Future<Map<String, dynamic>> getUserPreferences(String userId) async {
  try {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/preferences'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      logger.e('Failed to get user preferences: ${response.statusCode}');
      return {};
    }
  } catch (e) {
    logger.e('Get user preferences error: $e');
    return {};
  }
}

// Update user preferences
Future<bool> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
  try {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/preferences'),
      headers: headers,
      body: jsonEncode(preferences),
    );
    
    return response.statusCode == 200;
  } catch (e) {
    logger.e('Update user preferences error: $e');
    return false;
  }
}
}

