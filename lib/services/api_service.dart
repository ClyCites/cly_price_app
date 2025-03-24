import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/price_data.dart';
import '../models/price_entry.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl = AppConstants.apiBaseUrl;
  
  // Helper method to get auth token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
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
  
  // ==================
  // Auth API Methods
  // ==================
  
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 201) {
        // Save token if registration includes login
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
        }
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Password reset request failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<void> resetPassword(String token, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password/$token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'password': password,
        }),
      );
      
      final data = json.decode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<User> getUserProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  // ==================
  // Price API Methods
  // ==================
  
  Future<List<Product>> getProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to load products');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<PriceData>> getPriceData(String product, String timeframe) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices?product=$product&timeframe=$timeframe'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PriceData.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to load price data');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<Product>> getTrendingProducts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices/trends/popular'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to load trending products');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<PriceEntry> submitPriceEntry(PriceEntry entry) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/prices'),
        headers: headers,
        body: json.encode(entry.toJson()),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return PriceEntry.fromJson(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to submit price entry');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<Map<String, dynamic>> predictPrice(String product, String market, String timeframe) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/prices/predict'),
        headers: headers,
        body: json.encode({
          'product': product,
          'market': market,
          'timeframe': timeframe,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to predict price');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<Map<String, dynamic>>> getPriceTrends(String product, String market) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices/trends/$product/$market'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get price trends');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<Map<String, dynamic>>> compareMarketPrices(String product) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices/compare?product=$product'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to compare market prices');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<PriceData>> getHistoricalPrices(String product, String market) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices/history/$product/$market'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PriceData.fromJson(json)).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get historical prices');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<void> setUserPriceAlert(String product, String market, double threshold) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/prices/alerts/set'),
        headers: headers,
        body: json.encode({
          'product': product,
          'market': market,
          'alertThreshold': threshold,
        }),
      );
      
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to set price alert');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
  
  Future<List<Map<String, dynamic>>> getAveragePricePerMarket(String product) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/prices/average/$product'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to get average prices');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

