import 'historical_price.dart';

class PriceData {
  final String? id;
  final String product;
  final String market;
  final double price;
  final String currency;
  final DateTime date;
  final DateTime lastUpdated;
  final String productType;
  final double quantity;
  final String unit;
  final double? predictedPrice;
  final DateTime? predictionDate;
  final double trendPercentage;
  final double priceChangePercentage;
  final double? alertThreshold;
  final bool alertTriggered;
  final List<HistoricalPrice> historicalPrices;
  final String category;
  final bool isValid;
  final String errorLog;
  final double volume;

  PriceData({
    this.id,
    required this.product,
    required this.market,
    required this.price,
    this.currency = 'UGX',
    required this.date,
    required this.lastUpdated,
    required this.productType,
    required this.quantity,
    required this.unit,
    this.predictedPrice,
    this.predictionDate,
    this.trendPercentage = 0,
    this.priceChangePercentage = 0,
    this.alertThreshold,
    this.alertTriggered = false,
    this.historicalPrices = const [],
    this.category = 'grain',
    this.isValid = true,
    this.errorLog = '',
    required this.volume,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    List<HistoricalPrice> historicalPrices = [];
    if (json['historicalPrices'] != null) {
      historicalPrices = List<HistoricalPrice>.from(
        json['historicalPrices'].map((x) => HistoricalPrice.fromJson(x)),
      );
    }

    return PriceData(
      id: json['_id'],
      product: json['product'],
      market: json['market'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'UGX',
      date: DateTime.parse(json['date']),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      productType: json['productType'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      predictedPrice: json['predictedPrice']?.toDouble(),
      predictionDate: json['predictionDate'] != null ? DateTime.parse(json['predictionDate']) : null,
      trendPercentage: json['trendPercentage']?.toDouble() ?? 0,
      priceChangePercentage: json['priceChangePercentage']?.toDouble() ?? 0,
      alertThreshold: json['alertThreshold']?.toDouble(),
      alertTriggered: json['alertTriggered'] ?? false,
      historicalPrices: historicalPrices,
      category: json['category'] ?? 'grain',
      isValid: json['isValid'] ?? true,
      errorLog: json['errorLog'] ?? '',
      volume: json['volume']?.toDouble() ?? 0,
    );
  }

  factory PriceData.fromMap(Map<String, dynamic> map) {
    return PriceData(
      id: map['id'],
      product: map['product'],
      market: map['market'],
      price: map['price'],
      currency: map['currency'],
      date: DateTime.parse(map['date']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      productType: map['productType'],
      quantity: map['quantity'],
      unit: map['unit'],
      predictedPrice: map['predictedPrice'],
      predictionDate: map['predictionDate'] != null ? DateTime.parse(map['predictionDate']) : null,
      trendPercentage: map['trendPercentage'],
      priceChangePercentage: map['priceChangePercentage'],
      alertThreshold: map['alertThreshold'],
      alertTriggered: map['alertTriggered'] == 1,
      historicalPrices: [], // SQLite doesn't store nested objects well
      category: map['category'],
      isValid: map['isValid'] == 1,
      errorLog: map['errorLog'] ?? '',
      volume: map['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'market': market,
      'price': price,
      'currency': currency,
      'date': date.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'productType': productType,
      'quantity': quantity,
      'unit': unit,
      'predictedPrice': predictedPrice,
      'predictionDate': predictionDate?.toIso8601String(),
      'trendPercentage': trendPercentage,
      'priceChangePercentage': priceChangePercentage,
      'alertThreshold': alertThreshold,
      'alertTriggered': alertTriggered,
      'historicalPrices': historicalPrices.map((x) => x.toJson()).toList(),
      'category': category,
      'isValid': isValid,
      'errorLog': errorLog,
      'volume': volume,
    };
  }

  // Create a copy with modified fields
  PriceData copyWith({
    String? id,
    String? product,
    String? market,
    double? price,
    String? currency,
    DateTime? date,
    DateTime? lastUpdated,
    String? productType,
    double? quantity,
    String? unit,
    double? predictedPrice,
    DateTime? predictionDate,
    double? trendPercentage,
    double? priceChangePercentage,
    double? alertThreshold,
    bool? alertTriggered,
    List<HistoricalPrice>? historicalPrices,
    String? category,
    bool? isValid,
    String? errorLog,
    double? volume,
  }) {
    return PriceData(
      id: id ?? this.id,
      product: product ?? this.product,
      market: market ?? this.market,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      productType: productType ?? this.productType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      predictedPrice: predictedPrice ?? this.predictedPrice,
      predictionDate: predictionDate ?? this.predictionDate,
      trendPercentage: trendPercentage ?? this.trendPercentage,
      priceChangePercentage: priceChangePercentage ?? this.priceChangePercentage,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      alertTriggered: alertTriggered ?? this.alertTriggered,
      historicalPrices: historicalPrices ?? this.historicalPrices,
      category: category ?? this.category,
      isValid: isValid ?? this.isValid,
      errorLog: errorLog ?? this.errorLog,
      volume: volume ?? this.volume,
    );
  }
}

