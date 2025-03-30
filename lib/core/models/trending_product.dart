class TrendingProduct {
  final String id;
  final String productName;
  final String productCategory;
  final String productDescription;
  final double currentPrice;
  final double trendPercentage;

  TrendingProduct({
    required this.id,
    required this.productName,
    required this.productCategory,
    required this.productDescription,
    required this.currentPrice,
    required this.trendPercentage,
  });

  factory TrendingProduct.fromJson(Map<String, dynamic> json) {
    return TrendingProduct(
      id: json['id'],
      productName: json['productName'],
      productCategory: json['productCategory'],
      productDescription: json['productDescription'],
      currentPrice: json['currentPrice'].toDouble(),
      trendPercentage: double.tryParse(json['trendPercentage'] ?? '0.0') ?? 0.0,
    );
  }

  factory TrendingProduct.fromMap(Map<String, dynamic> map) {
    return TrendingProduct(
      id: map['id'],
      productName: map['productName'],
      productCategory: map['productCategory'],
      productDescription: map['productDescription'],
      currentPrice: map['currentPrice'],
      trendPercentage: map['trendPercentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productIdName': productName,
      'productCategory': productCategory,
      'productDescription': productDescription,
      'currentPrice': currentPrice,
      'trendPercentage': trendPercentage,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

}
