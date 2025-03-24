import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/price_data.dart';
import '../models/price_entry.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<Product> _products = [];
  List<PriceData> _priceData = [];
  List<Product> _trendingProducts = [];
  
  double _currentPrice = 0;
  double _priceChange = 0;
  double _priceChangePercentage = 0;
  
  bool _isOffline = false;
  
  List<Product> get products => _products;
  List<PriceData> get priceData => _priceData;
  List<Product> get trendingProducts => _trendingProducts;
  
  double get currentPrice => _currentPrice;
  double get priceChange => _priceChange;
  double get priceChangePercentage => _priceChangePercentage;
  
  bool get isOffline => _isOffline;
  
  Future<void> fetchProducts() async {
    try {
      final products = await _apiService.getProducts();
      _products = products;
      
      // Cache products locally
      await _databaseService.cacheProducts(products);
      
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedProducts = await _databaseService.getCachedProducts();
        _products = cachedProducts;
        _isOffline = true;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _products = [];
        _isOffline = true;
        notifyListeners();
        rethrow;
      }
    }
  }
  
  Future<void> fetchPriceData(String product, String timeframe) async {
    try {
      final data = await _apiService.getPriceData(product, timeframe);
      _priceData = data;
      
      if (data.isNotEmpty) {
        // Calculate current price and changes
        _currentPrice = data.last.price;
        
        if (data.length > 1) {
          final previousPrice = data[data.length - 2].price;
          _priceChange = _currentPrice - previousPrice;
          _priceChangePercentage = (_priceChange / previousPrice) * 100;
        } else {
          _priceChange = 0;
          _priceChangePercentage = 0;
        }
      }
      
      // Cache price data locally
      await _databaseService.cachePriceData(product, timeframe, data);
      
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedData = await _databaseService.getCachedPriceData(product, timeframe);
        _priceData = cachedData;
        
        if (cachedData.isNotEmpty) {
          _currentPrice = cachedData.last.price;
          
          if (cachedData.length > 1) {
            final previousPrice = cachedData[cachedData.length - 2].price;
            _priceChange = _currentPrice - previousPrice;
            _priceChangePercentage = (_priceChange / previousPrice) * 100;
          } else {
            _priceChange = 0;
            _priceChangePercentage = 0;
          }
        }
        
        _isOffline = true;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _priceData = [];
        _currentPrice = 0;
        _priceChange = 0;
        _priceChangePercentage = 0;
        _isOffline = true;
        notifyListeners();
        rethrow;
      }
    }
    
    // Also fetch trending products
    await fetchTrendingProducts();
  }
  
  Future<void> fetchTrendingProducts() async {
    try {
      final trending = await _apiService.getTrendingProducts();
      _trendingProducts = trending;
      
      // Cache trending products locally
      await _databaseService.cacheTrendingProducts(trending);
      
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedTrending = await _databaseService.getCachedTrendingProducts();
        _trendingProducts = cachedTrending;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _trendingProducts = [];
        notifyListeners();
      }
    }
  }
  
  Future<void> submitPriceEntry(PriceEntry entry) async {
    try {
      // Try to submit to API first
      final submittedEntry = await _apiService.submitPriceEntry(entry);
      
      // Cache the submitted entry locally
      await _databaseService.cachePriceEntry(submittedEntry);
      
      _isOffline = false;
    } catch (e) {
      // If API submission fails, store locally for later sync
      final pendingEntry = entry.copyWith(status: 'pending');
      await _databaseService.storePendingPriceEntry(pendingEntry);
      
      _isOffline = true;
      throw Exception('Stored offline. Will sync when connection is restored.');
    }
  }
  
  Future<void> syncPendingEntries() async {
    try {
      final pendingEntries = await _databaseService.getPendingPriceEntries();
      
      for (final entry in pendingEntries) {
        try {
          final submittedEntry = await _apiService.submitPriceEntry(entry);
          await _databaseService.removePendingPriceEntry(entry.id);
          await _databaseService.cachePriceEntry(submittedEntry);
        } catch (e) {
          // Skip this entry and try the next one
          continue;
        }
      }
      
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      // If sync fails, remain in offline mode
      _isOffline = true;
      notifyListeners();
      rethrow;
    }
  }
}

