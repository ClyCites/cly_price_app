import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import '../models/trending_product.dart';  // Import your TrendingProduct model file
import '../services/service_locator.dart';  // Assuming service locator is properly set up
import 'package:logging/logging.dart'; 


class TrendingProductProvider with ChangeNotifier {
  static final Logger _logger = Logger('TrendingProductsProvider'); // Logger instance
  List<TrendingProduct> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<TrendingProduct> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Fetch trending products from the API and cache them
  Future<void> fetchTrendingProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final trending = await serviceLocator.apiService.getTrendingProducts();
      
      // Cache the trending products in the database (optional)
      await serviceLocator.databaseService.cacheTrendingProducts(trending);

      _products = trending; // Assuming the API returns a list of TrendingProduct objects
      _errorMessage = '';  // Clear any previous error messages
      notifyListeners();
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      try {
        final cachedTrending = await serviceLocator.databaseService.getCachedTrendingProducts();
        _products = cachedTrending;
        notifyListeners();
      } catch (cacheError) {
        _logger.severe('Failed to load cached trending products: $cacheError');
        _products = [];
        notifyListeners();
      }
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }
}
