import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../models/price_data.dart'; // Ensure PriceData class is imported
import '../models/price_entry.dart'; // Ensure PriceEntry class is imported
import '../models/product.dart'; // Ensure Product class is imported
import '../services/service_locator.dart';
import '../api/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<PriceData> _priceData = [];
  List<Product> _trendingProducts = [];
  List<String> _markets = [];
  final ApiService _apiService = ApiService();

  double _currentPrice = 0;
  double _priceChange = 0;
  double _priceChangePercentage = 0;

  bool _isOffline = false;
  bool _isLoading = false;

  List<Product> get products => _products;
  List<PriceData> get priceData => _priceData;
  List<Product> get trendingProducts => _trendingProducts;
  List<String> get markets => _markets;
  ApiService get apiService => _apiService;
  

  double get currentPrice => _currentPrice;
  double get priceChange => _priceChange;
  double get priceChangePercentage => _priceChangePercentage;

  bool get isOffline => _isOffline;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final products = await serviceLocator.apiService.getProducts();
      _products = products;

      // Cache products locally
      await serviceLocator.databaseService.cacheProducts(products);

      _isOffline = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedProducts =
            await serviceLocator.databaseService.getCachedProducts();
        _products = cachedProducts;
        _isOffline = true;
        _isLoading = false;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _products = [];
        _isOffline = true;
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> compareMarketPrices(
      String productName) async {
    // Implement the method to compare market prices
    // This is a placeholder implementation
    await Future.delayed(Duration(seconds: 2));
    return [
      {'market': 'Market 1', 'price': 100},
      {'market': 'Market 2', 'price': 110},
    ];
  }

  Future<void> fetchPriceData(String product, String timeframe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data =
          await serviceLocator.apiService.getPriceData(product, timeframe);
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
      await serviceLocator.databaseService
          .cachePriceData(product, timeframe, data);

      _isOffline = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedData = await serviceLocator.databaseService
            .getCachedPriceData(product, timeframe);
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
        _isLoading = false;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _priceData = [];
        _currentPrice = 0;
        _priceChange = 0;
        _priceChangePercentage = 0;
        _isOffline = true;
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    }

    // Also fetch trending products
    await fetchTrendingProducts();
  }

  Future<void> fetchTrendingProducts() async {
    try {
      final trending = await serviceLocator.apiService.getTrendingProducts();
      _trendingProducts = trending;

      // Cache trending products locally
      await serviceLocator.databaseService.cacheTrendingProducts(trending);

      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedTrending =
            await serviceLocator.databaseService.getCachedTrendingProducts();
        _trendingProducts = cachedTrending;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _trendingProducts = [];
        notifyListeners();
      }
    }
  }

  Future<void> fetchMarkets() async {
    try {
      final markets = await serviceLocator.apiService.getMarkets();
      _markets = markets;
      notifyListeners();
    } catch (e) {
      // If API fails, try to load from local cache
      try {
        final cachedMarkets =
            await serviceLocator.databaseService.getCachedMarkets();
        _markets = cachedMarkets;
        notifyListeners();
      } catch (cacheError) {
        // If both fail, set empty list
        _markets = [];
        notifyListeners();
      }
    }
  }

  Future<void> submitPriceEntry(PriceEntry entry) async {
    try {
      // Try to submit to API first
      final submittedEntry =
          await serviceLocator.apiService.submitPriceEntry(entry);

      // Cache the submitted entry locally
      await serviceLocator.databaseService.cachePriceEntry(submittedEntry);

      _isOffline = false;
    } catch (e) {
      // If API submission fails, store locally for later sync
      final pendingEntry = entry.copyWith(status: 'pending');
      await serviceLocator.databaseService.storePendingPriceEntry(pendingEntry);

      _isOffline = true;
      throw Exception('Stored offline. Will sync when connection is restored.');
    }
  }

  Future<void> syncPendingEntries() async {
    try {
      final pendingEntries =
          await serviceLocator.databaseService.getPendingPriceEntries();

      for (final entry in pendingEntries) {
        try {
          final submittedEntry =
              await serviceLocator.apiService.submitPriceEntry(entry);
          await serviceLocator.databaseService
              .removePendingPriceEntry(entry.id);
          await serviceLocator.databaseService.cachePriceEntry(submittedEntry);
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
