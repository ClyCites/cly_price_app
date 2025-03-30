import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';
import '../models/price_data.dart';
import '../models/price_entry.dart';
import '../services/service_locator.dart';
import '../models/trending_product.dart';
import '../utils/app_logger.dart';

class DatabaseService {
  late Database _database;
  final logger = serviceLocator.logger;
  
  Future<void> initialize() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);
    
    _database = await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
    
    logger.i('Database initialized at $path');
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE ${AppConstants.productsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        productType TEXT NOT NULL,
        defaultUnit TEXT NOT NULL,
        imageUrl TEXT,
        isPopular INTEGER NOT NULL DEFAULT 0,
        currentPrice REAL NOT NULL DEFAULT 0,
        priceChange REAL NOT NULL DEFAULT 0,
        priceChangePercentage REAL NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.trendingProductsTable} (
        id TEXT PRIMARY KEY,
        productIdName TEXT NOT NULL,
        productCategory TEXT NOT NULL,
        productDescription TEXT NOT NULL,
        currentPrice REAL NOT NULL DEFAULT 0,
        trendPercentage REAL NOT NULL DEFAULT 0,
        lastUpdated TEXT NOT NULL,
      )
    ''');
    
    // Price data table
    await db.execute('''
      CREATE TABLE ${AppConstants.priceDataTable} (
        id TEXT PRIMARY KEY,
        product TEXT NOT NULL,
        market TEXT NOT NULL,
        price REAL NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        productType TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        predictedPrice REAL,
        predictionDate TEXT,
        trendPercentage REAL NOT NULL DEFAULT 0,
        priceChangePercentage REAL NOT NULL DEFAULT 0,
        alertThreshold REAL,
        alertTriggered INTEGER NOT NULL DEFAULT 0,
        category TEXT NOT NULL,
        isValid INTEGER NOT NULL DEFAULT 1,
        errorLog TEXT,
        volume REAL NOT NULL DEFAULT 0,
        timeframe TEXT NOT NULL
      )
    ''');

    
    
    // Price entries table (for offline storage)
    await db.execute('''
      CREATE TABLE ${AppConstants.priceEntriesTable} (
        id TEXT PRIMARY KEY,
        productName TEXT NOT NULL,
        market TEXT NOT NULL,
        price REAL NOT NULL,
        currency TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        productType TEXT NOT NULL,
        location TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        date TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        category TEXT NOT NULL,
        syncStatus TEXT NOT NULL DEFAULT 'pending'
      )
    ''');
    
    // Markets table
    await db.execute('''
      CREATE TABLE ${AppConstants.marketsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT,
        latitude REAL,
        longitude REAL,
        lastUpdated TEXT NOT NULL
      )
    ''');
    
    logger.i('Database tables created');
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2) {
      // Example migration for version 2
    }
  }
  
  // ==================
  // Products Methods
  // ==================
  
  Future<void> cacheProducts(List<Product> products) async {
    final batch = _database.batch();
    
    // Clear existing products
    batch.delete(AppConstants.productsTable);
    
    // Insert new products
    for (final product in products) {
      batch.insert(
        AppConstants.productsTable,
        {
          'id': product.id,
          'name': product.name,
          'category': product.category,
          'productType': product.productType,
          'defaultUnit': product.defaultUnit,
          'imageUrl': product.imageUrl,
          'isPopular': product.isPopular ? 1 : 0,
          'currentPrice': product.currentPrice,
          'priceChange': product.priceChange,
          'priceChangePercentage': product.priceChangePercentage,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    }
    
    await batch.commit();
    logger.i('Cached ${products.length} products');
  }
  
  Future<List<Product>> getCachedProducts() async {
    final maps = await _database.query(AppConstants.productsTable);
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
  
  // ==================
  // Price Data Methods
  // ==================
  
  Future<void> cachePriceData(String product, String timeframe, List<PriceData> data) async {
    final batch = _database.batch();
    
    // Clear existing price data for this product and timeframe
    batch.delete(
      AppConstants.priceDataTable,
      where: 'product = ? AND timeframe = ?',
      whereArgs: [product, timeframe],
    );
    
    // Insert new price data
    for (final priceData in data) {
      batch.insert(
        AppConstants.priceDataTable,
        {
          'id': priceData.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'product': priceData.product,
          'market': priceData.market,
          'price': priceData.price,
          'currency': priceData.currency,
          'date': priceData.date.toIso8601String(),
          'lastUpdated': priceData.lastUpdated.toIso8601String(),
          'productType': priceData.productType,
          'quantity': priceData.quantity,
          'unit': priceData.unit,
          'predictedPrice': priceData.predictedPrice,
          'predictionDate': priceData.predictionDate?.toIso8601String(),
          'trendPercentage': priceData.trendPercentage,
          'priceChangePercentage': priceData.priceChangePercentage,
          'alertThreshold': priceData.alertThreshold,
          'alertTriggered': priceData.alertTriggered ? 1 : 0,
          'category': priceData.category,
          'isValid': priceData.isValid ? 1 : 0,
          'errorLog': priceData.errorLog,
          'volume': priceData.volume,
          'timeframe': timeframe,
        },
      );
    }
    
    await batch.commit();
    logger.i('Cached ${data.length} price data points for $product ($timeframe)');
  }
  
  Future<List<PriceData>> getCachedPriceData(String product, String timeframe) async {
    final maps = await _database.query(
      AppConstants.priceDataTable,
      where: 'product = ? AND timeframe = ?',
      whereArgs: [product, timeframe],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) {
      return PriceData.fromMap(maps[i]);
    });
  }
  
  // ==================
  // Price Entry Methods
  // ==================
  
  Future<void> cachePriceEntry(PriceEntry entry) async {
    await _database.insert(
      AppConstants.priceEntriesTable,
      {
        'id': entry.id,
        'productName': entry.productName,
        'market': entry.market,
        'price': entry.price,
        'currency': entry.currency,
        'quantity': entry.quantity,
        'unit': entry.unit,
        'productType': entry.productType,
        'location': entry.location,
        'latitude': entry.latitude,
        'longitude': entry.longitude,
        'date': entry.date.toIso8601String(),
        'notes': entry.notes,
        'status': entry.status,
        'category': entry.category,
        'syncStatus': 'synced',
      },
    );
    
    logger.i('Cached price entry for ${entry.productName}');
  }
  
  Future<void> storePendingPriceEntry(PriceEntry entry) async {
    await _database.insert(
      AppConstants.priceEntriesTable,
      {
        'id': entry.id,
        'productName': entry.productName,
        'market': entry.market,
        'price': entry.price,
        'currency': entry.currency,
        'quantity': entry.quantity,
        'unit': entry.unit,
        'productType': entry.productType,
        'location': entry.location,
        'latitude': entry.latitude,
        'longitude': entry.longitude,
        'date': entry.date.toIso8601String(),
        'notes': entry.notes,
        'status': entry.status,
        'category': entry.category,
        'syncStatus': 'pending',
      },
    );
    
    logger.i('Stored pending price entry for ${entry.productName}');
  }
  
  Future<List<PriceEntry>> getPendingPriceEntries() async {
    final maps = await _database.query(
      AppConstants.priceEntriesTable,
      where: 'syncStatus = ?',
      whereArgs: ['pending'],
    );
    
    return List.generate(maps.length, (i) {
      return PriceEntry.fromMap(maps[i]);
    });
  }
  
  Future<void> removePendingPriceEntry(String id) async {
    await _database.delete(
      AppConstants.priceEntriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    logger.i('Removed pending price entry: $id');
  }
  
  // ==================
  // Trending Products Methods
  // ==================
  
  Future<void> cacheTrendingProducts(List<TrendingProduct> products) async {
    final batch = _database.batch();

    // Clear existing trending products
    batch.delete(AppConstants.trendingProductsTable);

    // Insert new trending products
    for (final product in products) {
      batch.insert(
        AppConstants.trendingProductsTable,
        {
          'id': product.id,
          'productIdName': product.productName,
          'productCategory': product.productCategory,
          'productDescription': product.productDescription,
          'currentPrice': product.currentPrice,
          'trendPercentage': product.trendPercentage,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    }

    await batch.commit();
    logger.i('Cached ${products.length} trending products');
  }


  
  Future<List<TrendingProduct>> getCachedTrendingProducts() async {
    final maps = await _database.query(AppConstants.trendingProductsTable);
    return List.generate(maps.length, (i) {
      return TrendingProduct.fromMap(maps[i]);
    });
  }
  
  // ==================
  // Markets Methods
  // ==================
  
  Future<void> cacheMarkets(List<Map<String, dynamic>> markets) async {
    final batch = _database.batch();
    
    // Clear existing markets
    batch.delete(AppConstants.marketsTable);
    
    // Insert new markets
    for (final market in markets) {
      batch.insert(
        AppConstants.marketsTable,
        {
          'id': market['id'],
          'name': market['name'],
          'location': market['location'],
          'latitude': market['latitude'],
          'longitude': market['longitude'],
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    }
    
    await batch.commit();
    logger.i('Cached ${markets.length} markets');
  }
  
  Future<List<String>> getCachedMarkets() async {
    final maps = await _database.query(AppConstants.marketsTable);
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }
}

