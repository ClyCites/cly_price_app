import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/trending_product.dart';  // Import your TrendingProduct model file

class TrendingProductProvider with ChangeNotifier {
  List<TrendingProduct> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<TrendingProduct> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch trending products from the API
  Future<void> fetchTrendingProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('YOUR_API_URL'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _products = data.map((item) => TrendingProduct.fromJson(item)).toList();
        _errorMessage = '';  // Clear any previous error messages
      } else {
        _errorMessage = 'Failed to load trending products';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    }

    _isLoading = false;
    notifyListeners();
  }
}
