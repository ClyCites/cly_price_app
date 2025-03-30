import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';  // Adding logging library

import '../models/models.dart';
import '../models/price_data.dart';
import '../models/price_entry.dart';
import '../models/product.dart';
import '../services/service_locator.dart';
import '../api/api_service.dart';

class ProductProvider with ChangeNotifier {
  static final Logger _logger = Logger('ProductProvider'); // Logger instance

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

      // Cache products locally with expiration time
      await serviceLocator.databaseService.cacheProducts(products);
      _isOffline = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.severe('Failed to fetch products from API: $e');
      try {
        final cachedProducts =
            await serviceLocator.databaseService.getCachedProducts();
        _products = cachedProducts;
        _isOffline = true;
        _isLoading = false;
        notifyListeners();
      } catch (cacheError) {
        _logger.severe('Failed to load cached products: $cacheError');
        _products = [];
        _isOffline = true;
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> compareMarketPrices(String productName) async {
    try {
      // Implement the method to compare market prices
      // Placeholder example:
      await Future.delayed(Duration(seconds: 2));
      return [
        {'market': 'Market 1', 'price': 100},
        {'market': 'Market 2', 'price': 110},
      ];
    } catch (e) {
      _logger.severe('Error comparing market prices: $e');
      rethrow;
    }
  }

  Future<void> fetchPriceData(String product, String timeframe) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await serviceLocator.apiService.getPriceData(product, timeframe);
      _priceData = data;

      if (data.isNotEmpty) {
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

      // Cache price data with a timestamp to track expiration
      await serviceLocator.databaseService.cachePriceData(product, timeframe, data);

      _isOffline = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _logger.severe('Failed to fetch price data: $e');
      try {
        final cachedData = await serviceLocator.databaseService.getCachedPriceData(product, timeframe);
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
        _logger.severe('Failed to load cached price data: $cacheError');
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

    // Fetch trending products
    // await fetchTrendingProducts();
  }

  // Future<void> fetchTrendingProducts() async {
  //   try {
  //     final trending = await serviceLocator.apiService.getTrendingProducts();
  //     _trendingProducts = trending;
  //     await serviceLocator.databaseService.cacheTrendingProducts(trending);
  //     notifyListeners();
  //   } catch (e) {
  //     _logger.severe('Failed to fetch trending products: $e');
  //     try {
  //       final cachedTrending = await serviceLocator.databaseService.getCachedTrendingProducts();
  //       _trendingProducts = cachedTrending;
  //       notifyListeners();
  //     } catch (cacheError) {
  //       _logger.severe('Failed to load cached trending products: $cacheError');
  //       _trendingProducts = [];
  //       notifyListeners();
  //     }
  //   }
  // }

  Future<void> fetchMarkets() async {
    try {
      final markets = await serviceLocator.apiService.getMarkets();
      _markets = markets;
      notifyListeners();
    } catch (e) {
      _logger.severe('Failed to fetch markets: $e');
      try {
        final cachedMarkets = await serviceLocator.databaseService.getCachedMarkets();
        _markets = cachedMarkets;
        notifyListeners();
      } catch (cacheError) {
        _logger.severe('Failed to load cached markets: $cacheError');
        _markets = [];
        notifyListeners();
      }
    }
  }

  Future<void> submitPriceEntry(PriceEntry entry) async {
    try {
      final submittedEntry = await serviceLocator.apiService.submitPriceEntry(entry);
      await serviceLocator.databaseService.cachePriceEntry(submittedEntry);
      _isOffline = false;
    } catch (e) {
      _logger.severe('Failed to submit price entry: $e');
      final pendingEntry = entry.copyWith(status: 'pending');
      await serviceLocator.databaseService.storePendingPriceEntry(pendingEntry);
      _isOffline = true;
      throw Exception('Stored offline. Will sync when connection is restored.');
    }
  }

  Future<void> syncPendingEntries() async {
    try {
      final pendingEntries = await serviceLocator.databaseService.getPendingPriceEntries();

      for (final entry in pendingEntries) {
        try {
          final submittedEntry = await serviceLocator.apiService.submitPriceEntry(entry);
          await serviceLocator.databaseService.removePendingPriceEntry(entry.id);
          await serviceLocator.databaseService.cachePriceEntry(submittedEntry);
        } catch (e) {
          _logger.warning('Failed to submit pending entry: $e');
          continue;
        }
      }

      _isOffline = false;
      notifyListeners();
    } catch (e) {
      _logger.severe('Failed to sync pending entries: $e');
      _isOffline = true;
      notifyListeners();
      rethrow;
    }
  }
}
