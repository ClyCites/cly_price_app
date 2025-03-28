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
  String _lastProductIdFetched = '';

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

  // Fetch market comparisons for a product by ID
  Future<void> fetchMarketsByProductId(String productId) async {
    // Don't proceed if product ID is empty or if we're already loading this product
    if (productId.isEmpty) {
      _setError(true, 'Product ID cannot be empty');
      return;
    }
    
    // Skip if we're already loading or if we've already loaded this product recently
    if (_isLoading && _lastProductIdFetched == productId) return;
    
    _setLoading(true);
    _lastProductIdFetched = productId;
    
    try {
      // Try to load from cache first
      final cachedComparisons = await _loadMarketComparisonsFromCache(productId);
      if (cachedComparisons.isNotEmpty) {
        _marketComparisons = cachedComparisons;
        _setLoading(false);
        _setError(false, null);
        notifyListeners();
      }
      
      // Fetch from API
      final apiService = serviceLocator.apiService;
      final comparisons = await apiService.compareMarketPrices(productId);
      
      _marketComparisons = comparisons;
      
      // Save to cache
      await _saveMarketComparisonsToCache(productId, comparisons);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error fetching market comparisons: $e');
      
      // If we don't have cached data, use mock data
      if (_marketComparisons.isEmpty) {
        _marketComparisons = _getMockMarketComparisons(productId);
      }
      
      _setLoading(false);
      _setError(true, 'Failed to load market comparisons: $e');
      notifyListeners();
    }
  }

  // Extract market name from market data
  String _extractMarketName(dynamic marketData) {
    if (marketData is String) {
      return marketData;
    } else if (marketData is Map) {
      // Try to get the name field from the map
      final name = marketData['name'];
      if (name is String) {
        return name;
      }
    }
    
    // If we can't extract a name, log the issue and return a default
    serviceLocator.logger.e('Could not extract market name from: $marketData');
    return 'Unknown Market';
  }

  // Find cheapest market for a product
  Market? findCheapestMarket(String productId) {
    if (_marketComparisons.isEmpty) return null;
    
    // Sort by price (lowest first)
    final sortedComparisons = List<Map<String, dynamic>>.from(_marketComparisons)
      ..sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    
    if (sortedComparisons.isEmpty) return null;
    
    // Create a Market object from the comparison data
    final cheapestComparison = sortedComparisons.first;
    final marketName = _extractMarketName(cheapestComparison['market']);
    
    return Market(
      id: marketName.hashCode.toString(),
      name: marketName,
      location: 'Unknown',
      currentPrice: _ensureDouble(cheapestComparison['price']),
      productId: productId,
    );
  }

  // Find most expensive market for a product
  Market? findMostExpensiveMarket(String productId) {
    if (_marketComparisons.isEmpty) return null;
    
    // Sort by price (highest first)
    final sortedComparisons = List<Map<String, dynamic>>.from(_marketComparisons)
      ..sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    
    if (sortedComparisons.isEmpty) return null;
    
    // Create a Market object from the comparison data
    final expensiveComparison = sortedComparisons.first;
    final marketName = _extractMarketName(expensiveComparison['market']);
    
    return Market(
      id: marketName.hashCode.toString(),
      name: marketName,
      location: 'Unknown',
      currentPrice: _ensureDouble(expensiveComparison['price']),
      productId: productId,
    );
  }

  // Convert num to double safely
  double _ensureDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is num) {
      return value.toDouble();
    }
    
    // If it's not a number, log the issue and return 0
    serviceLocator.logger.e('Value is not a number: $value');
    return 0.0;
  }

  // Get average price for a product across all markets
  double getAveragePrice(String productId) {
    if (_marketComparisons.isEmpty) return 0;
    
    double totalPrice = 0;
    for (final comparison in _marketComparisons) {
      totalPrice += _ensureDouble(comparison['price']);
    }
    
    return totalPrice / _marketComparisons.length;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(bool hasError, String? message) {
    _hasError = hasError;
    _errorMessage = message;
  }

  // Cache management for markets
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

  Future<void> addMarket(Market market) async {
    _setLoading(true);
    
    try {
      // Try to add to API
      final apiService = serviceLocator.apiService;
      final addedMarket = await apiService.createMarket(market);
      
      // Add to local list
      _markets.add(addedMarket);
      
      // Update cache
      await _saveMarketsToCache(_markets);
      
      _setLoading(false);
      _setError(false, null);
      notifyListeners();
    } catch (e) {
      serviceLocator.logger.e('Error adding market: $e');
      
      // In development or if API fails, still add to local list
      if (kDebugMode) {
        _markets.add(market);
        await _saveMarketsToCache(_markets);
        _setLoading(false);
        notifyListeners();
      } else {
        _setLoading(false);
        _setError(true, 'Failed to add market: $e');
        notifyListeners();
        throw e; // Re-throw to handle in UI
      }
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

  // Cache management for market comparisons
  Future<void> _saveMarketComparisonsToCache(String productId, List<Map<String, dynamic>> comparisons) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final comparisonsJson = comparisons.map((comparison) => jsonEncode(comparison)).toList();
      await prefs.setStringList('cached_market_comparisons_$productId', comparisonsJson);
      await prefs.setString('market_comparisons_cache_time_$productId', DateTime.now().toIso8601String());
    } catch (e) {
      serviceLocator.logger.e('Error saving market comparisons to cache: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadMarketComparisonsFromCache(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final comparisonsJson = prefs.getStringList('cached_market_comparisons_$productId') ?? [];
      final cacheTimeStr = prefs.getString('market_comparisons_cache_time_$productId');
      
      if (cacheTimeStr != null) {
        final cacheTime = DateTime.parse(cacheTimeStr);
        final difference = DateTime.now().difference(cacheTime);
        
        if (difference > _cacheDuration) {
          return []; // Cache expired
        }
      }
      
      return comparisonsJson
          .map((comparisonStr) => jsonDecode(comparisonStr) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      serviceLocator.logger.e('Error loading market comparisons from cache: $e');
      return [];
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_markets');
      await prefs.remove('markets_cache_time');
      
      // Also clear product-specific caches
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('cached_market_comparisons_') || 
            key.startsWith('market_comparisons_cache_time_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      serviceLocator.logger.e('Error clearing market cache: $e');
    }
  }

  // Clear cache for a specific product
  Future<void> clearProductCache(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_market_comparisons_$productId');
      await prefs.remove('market_comparisons_cache_time_$productId');
    } catch (e) {
      serviceLocator.logger.e('Error clearing product cache: $e');
    }
  }

  // Mock data for market comparisons
  List<Map<String, dynamic>> _getMockMarketComparisons(String productId) {
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
        contactInfo: '+256 701 234567',
        description: 'The largest market in Kampala with a wide variety of agricultural products.',
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
        contactInfo: '+256 702 345678',
        description: 'A premium market known for high-quality fresh produce.',
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
        contactInfo: '+256 703 456789',
        description: 'A bustling market with affordable prices for all products.',
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
        contactInfo: '+256 704 567890',
        description: 'Known for wholesale agricultural products at competitive prices.',
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
        contactInfo: '+256 705 678901',
        description: 'A convenient market near the university with fresh produce.',
      ),
    ];
  }
}

