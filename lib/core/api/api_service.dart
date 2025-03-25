import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../models/user.dart'; // Add this line to import the User class
import '../models/product.dart'; // Add this line to import the Product class
import '../models/price_data.dart'; // Add this line to import the PriceData class
import '../models/price_entry.dart'; // Add this line to import the PriceEntry class
import '../services/service_locator.dart';
import '../utils/app_logger.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;
  final logger = serviceLocator.logger;
  
  // Helper method to get auth token
  Future<String?> _getToken() async {
    final prefs = serviceLocator.preferences;
    return prefs.getString('token');
  }
  
  // Helper method to create headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
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
  
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final data = await _post('auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    
    // Save token if registration includes login
    if (data['token'] != null) {
      final prefs = serviceLocator.preferences;
      await prefs.setString(AppConstants.prefToken, data['token']);
      if (data['user'] != null && data['user']['_id'] != null) {
        await prefs.setString(AppConstants.prefUserId, data['user']['_id']);
      }
    }
    
    return data;
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('auth/login', {
      'email': email,
      'password': password,
    });
    
    // Save token
    final prefs = serviceLocator.preferences;
    await prefs.setString(AppConstants.prefToken, data['token']);
    if (data['user'] != null && data['user']['_id'] != null) {
      await prefs.setString(AppConstants.prefUserId, data['user']['_id']);
    }
    
    return data;
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
  
  Future<User> getUserProfile() async {
    final data = await _get('auth/profile');
    return User.fromJson(data);
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
}

