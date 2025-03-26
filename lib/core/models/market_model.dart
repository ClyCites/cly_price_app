class Market {
  final String id;
  final String name;
  final String location;
  final String? region;
  final String? country;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime? lastUpdated;
  final double? currentPrice;
  final String? productId;

  Market({
    required this.id,
    required this.name,
    required this.location,
    this.region,
    this.country,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.lastUpdated,
    this.currentPrice,
    this.productId,
  });

  Market copyWith({
    String? id,
    String? name,
    String? location,
    String? region,
    String? country,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? lastUpdated,
    double? currentPrice,
    String? productId,
  }) {
    return Market(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      region: region ?? this.region,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentPrice: currentPrice ?? this.currentPrice,
      productId: productId ?? this.productId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'currentPrice': currentPrice,
      'productId': productId,
    };
  }

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      region: json['region'],
      country: json['country'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      isActive: json['isActive'] ?? true,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
      currentPrice: json['currentPrice'] != null ? double.parse(json['currentPrice'].toString()) : null,
      productId: json['productId'],
    );
  }

  static List<Market> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Market.fromJson(json)).toList();
  }

  @override
  String toString() {
    return 'Market(id: $id, name: $name, location: $location)';
  }
}

class MarketPrice {
  final String marketId;
  final String marketName;
  final double price;
  final DateTime date;
  final double? volume;
  final String? unit;
  final double? trendPercentage;

  MarketPrice({
    required this.marketId,
    required this.marketName,
    required this.price,
    required this.date,
    this.volume,
    this.unit,
    this.trendPercentage,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      marketId: json['marketId'] ?? json['market'] ?? '',
      marketName: json['marketName'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      volume: json['volume'] != null ? double.parse(json['volume'].toString()) : null,
      unit: json['unit'],
      trendPercentage: json['trendPercentage'] != null ? double.parse(json['trendPercentage'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'marketId': marketId,
      'marketName': marketName,
      'price': price,
      'date': date.toIso8601String(),
      'volume': volume,
      'unit': unit,
      'trendPercentage': trendPercentage,
    };
  }
}

class PriceComparison {
  final String market;
  final double price;
  final String? date;
  final double? volume;
  final String? unit;
  final double? trendPercentage;

  PriceComparison({
    required this.market,
    required this.price,
    this.date,
    this.volume,
    this.unit,
    this.trendPercentage,
  });

  factory PriceComparison.fromJson(Map<String, dynamic> json) {
    return PriceComparison(
      market: json['market'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      date: json['date'],
      volume: json['volume'] != null ? double.parse(json['volume'].toString()) : null,
      unit: json['unit'],
      trendPercentage: json['trendPercentage'] != null ? double.parse(json['trendPercentage'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'market': market,
      'price': price,
      'date': date,
      'volume': volume,
      'unit': unit,
      'trendPercentage': trendPercentage,
    };
  }
}

