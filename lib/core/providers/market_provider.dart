import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/market_model.dart';
import '../services/service_locator.dart';
import '../utils/app_logger.dart';

class MarketProvider with ChangeNotifier {
  List<Market> _markets = [];
  List<Map<String, dynamic>> _marketComparisons = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  // Cache management
  final Duration _cacheDuration = const Duration(hours: 1);
  DateTime? _lastFetchTime;

  // Getters
  List<Market> get markets => _markets;
  List<Map<String, dynamic>> get marketComparisons => _marketComparisons;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  // Initialize and load markets
  Future<void> initialize() async {
    await fetchMarkets();
  }

  // Fetch all markets
  Future<void> fetchMarkets({bool forceRefresh = false}) async {
    if (_isLoading) return;
    
    if (!forceRefresh && _markets.isNotEmpty && _lastFetchTime != null) {
      final difference = DateTime.now().difference(_lastFetchTime!);
      if (difference < _cacheDuration) {
        return; // Use cached data
      }
    }

    _setLoading(true);
    
    try {
      // Try to load from cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedMarkets = await _loadMarketsFromCache();
        if (cachedMarkets.isNotEmpty) {
          _markets = cachedMarkets;
          _setLoading(false);
          notifyListeners();
        }
      }
      
      // Fetch from API
      final apiService = serviceLocator.apiService;
      List<String> marketNames = await apiService.getMarkets();
      
      // Convert market names to Market objects
      _markets = marketNames.map((name) => Market(
        id: name.hashCode.toString(), // Generate a temporary ID
        name: name,
        location: 'Unknown', // Default values since the API only returns names
      )).toList();
      
      _lastFetchTime = DateTime.now();
      
      // Save to cache
      await _saveMarketsToCache(_markets);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error fetching markets: $e');
      _setLoading(false);
      _setError(true, 'Failed to load markets: $e');
      notifyListeners();
      
      // If API fails, use mock data in development
      if (kDebugMode) {
        _markets = _getMockMarkets();
        notifyListeners();
      }
    }
  }

  // Fetch market comparisons for a product
  Future<void> fetchMarketsByProduct(String productName) async {
    // Don't proceed if product name is empty
    if (productName.isEmpty) {
      _setError(true, 'Product name cannot be empty');
      _marketComparisons = _getMockMarketComparisons('Default');
      notifyListeners();
      return;
    }

    _setLoading(true);
    
    try {
      final apiService = serviceLocator.apiService;
      _marketComparisons = await apiService.compareMarketPrices(productName);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error fetching market comparisons: $e');
      _setLoading(false);
      _setError(true, 'Failed to load market comparisons: $e');
      
      // Always use mock data when API fails
      _marketComparisons = _getMockMarketComparisons(productName);
      notifyListeners();
    }
  }

  // Get markets by product
  List<Market> getMarketsByProduct(String productName) {
    // In a real implementation, this would filter markets by product
    // For now, we'll just return all markets
    return _markets;
  }

  // Find cheapest market for a product
  Market? findCheapestMarket(String productName) {
    if (_marketComparisons.isEmpty) return null;
    
    // Sort by price (lowest first)
    final sortedComparisons = List<Map<String, dynamic>>.from(_marketComparisons)
      ..sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    
    if (sortedComparisons.isEmpty) return null;
    
    // Create a Market object from the comparison data
    final cheapestComparison = sortedComparisons.first;
    return Market(
      id: cheapestComparison['market'].hashCode.toString(),
      name: cheapestComparison['market'] as String,
      location: 'Unknown',
      currentPrice: cheapestComparison['price'] as double,
      productId: productName,
    );
  }

  // Find most expensive market for a product
  Market? findMostExpensiveMarket(String productName) {
    if (_marketComparisons.isEmpty) return null;
    
    // Sort by price (highest first)
    final sortedComparisons = List<Map<String, dynamic>>.from(_marketComparisons)
      ..sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    
    if (sortedComparisons.isEmpty) return null;
    
    // Create a Market object from the comparison data
    final expensiveComparison = sortedComparisons.first;
    return Market(
      id: expensiveComparison['market'].hashCode.toString(),
      name: expensiveComparison['market'] as String,
      location: 'Unknown',
      currentPrice: expensiveComparison['price'] as double,
      productId: productName,
    );
  }

  // Get average price for a product across all markets
  double getAveragePrice(String productName) {
    if (_marketComparisons.isEmpty) return 0;
    
    double totalPrice = 0;
    for (final comparison in _marketComparisons) {
      totalPrice += comparison['price'] as double;
    }
    
    return totalPrice / _marketComparisons.length;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(bool hasError, String? message) {
    _hasError = hasError;
    _errorMessage = message;
    notifyListeners();
  }

  // Cache management
  Future<void> _saveMarketsToCache(List<Market> markets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final marketsJson = markets.map((market) => jsonEncode(market.toJson())).toList();
      await prefs.setStringList('cached_markets', marketsJson);
      await prefs.setString('markets_cache_time', DateTime.now().toIso8601String());
    } catch (e) {
      serviceLocator.logger.e('Error saving markets to cache: $e');
    }
  }

  Future<List<Market>> _loadMarketsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final marketsJson = prefs.getStringList('cached_markets') ?? [];
      final cacheTimeStr = prefs.getString('markets_cache_time');
      
      if (cacheTimeStr != null) {
        final cacheTime = DateTime.parse(cacheTimeStr);
        final difference = DateTime.now().difference(cacheTime);
        
        if (difference > _cacheDuration) {
          return []; // Cache expired
        }
      }
      
      return marketsJson
          .map((marketStr) => Market.fromJson(jsonDecode(marketStr)))
          .toList();
    } catch (e) {
      serviceLocator.logger.e('Error loading markets from cache: $e');
      return [];
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_markets');
      await prefs.remove('markets_cache_time');
    } catch (e) {
      serviceLocator.logger.e('Error clearing market cache: $e');
    }
  }

  // Mock data for offline development
  List<Map<String, dynamic>> _getMockMarketComparisons(String productName) {
    return [
      {
        'market': 'Kampala Central Market',
        'price': 2500.0,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'volume': 1000.0,
        'unit': 'kg',
        'trendPercentage': 2.5,
      },
      {
        'market': 'Nakasero Market',
        'price': 2300.0,
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'volume': 800.0,
        'unit': 'kg',
        'trendPercentage': -1.2,
      },
      {
        'market': 'Owino Market',
        'price': 2400.0,
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'volume': 1200.0,
        'unit': 'kg',
        'trendPercentage': 0.8,
      },
      {
        'market': 'Kalerwe Market',
        'price': 2200.0,
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'volume': 600.0,
        'unit': 'kg',
        'trendPercentage': -2.0,
      },
      {
        'market': 'Wandegeya Market',
        'price': 2600.0,
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'volume': 500.0,
        'unit': 'kg',
        'trendPercentage': 3.5,
      },
    ];
  }

  // Mock data for markets
  List<Market> _getMockMarkets() {
    return [
      Market(
        id: '1',
        name: 'Kampala Central Market',
        location: 'Kampala',
        region: 'Central',
        country: 'Uganda',
        latitude: 0.3136,
        longitude: 32.5811,
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      Market(
        id: '2',
        name: 'Nakasero Market',
        location: 'Kampala',
        region: 'Central',
        country: 'Uganda',
        latitude: 0.3149,
        longitude: 32.5767,
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      Market(
        id: '3',
        name: 'Owino Market',
        location: 'Kampala',
        region: 'Central',
        country: 'Uganda',
        latitude: 0.3103,
        longitude: 32.5844,
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      Market(
        id: '4',
        name: 'Kalerwe Market',
        location: 'Kampala',
        region: 'Central',
        country: 'Uganda',
        latitude: 0.3428,
        longitude: 32.5728,
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
      Market(
        id: '5',
        name: 'Wandegeya Market',
        location: 'Kampala',
        region: 'Central',
        country: 'Uganda',
        latitude: 0.3308,
        longitude: 32.5744,
        isActive: true,
        lastUpdated: DateTime.now(),
      ),
    ];
  }
}

