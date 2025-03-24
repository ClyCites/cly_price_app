class Product {
  final String id;
  final String name;
  final String category;
  final String productType; // 'solid' or 'liquid'
  final String defaultUnit; // 'kg' or 'liters'
  final String imageUrl;
  final bool isPopular;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercentage;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.productType,
    required this.defaultUnit,
    this.imageUrl = '',
    this.isPopular = false,
    required this.currentPrice,
    this.priceChange = 0,
    this.priceChangePercentage = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      category: json['category'] ?? 'grain',
      productType: json['productType'] ?? 'solid',
      defaultUnit: json['defaultUnit'] ?? 'kg',
      imageUrl: json['imageUrl'] ?? '',
      isPopular: json['isPopular'] ?? false,
      currentPrice: json['currentPrice']?.toDouble() ?? 0,
      priceChange: json['priceChange']?.toDouble() ?? 0,
      priceChangePercentage: json['priceChangePercentage']?.toDouble() ?? 0,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      productType: map['productType'],
      defaultUnit: map['defaultUnit'],
      imageUrl: map['imageUrl'] ?? '',
      isPopular: map['isPopular'] == 1,
      currentPrice: map['currentPrice'],
      priceChange: map['priceChange'],
      priceChangePercentage: map['priceChangePercentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'productType': productType,
      'defaultUnit': defaultUnit,
      'imageUrl': imageUrl,
      'isPopular': isPopular,
      'currentPrice': currentPrice,
      'priceChange': priceChange,
      'priceChangePercentage': priceChangePercentage,
    };
  }
}

