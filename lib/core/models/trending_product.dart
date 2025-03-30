class TrendingProduct {
  final String id;
  final String name;
  final String category;
  final String description;
  final double currentPrice;
  final double trendPercentage;

  TrendingProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.currentPrice,
    required this.trendPercentage,
  });

  factory TrendingProduct.fromJson(Map<String, dynamic> json) {
    return TrendingProduct(
      id: json['productId'],
      name: json['productName'],
      category: json['productCategory'],
      description: json['productDescription'],
      currentPrice: json['currentPrice'].toDouble(),
      trendPercentage: double.tryParse(json['trendPercentage'] ?? '0.0') ?? 0.0,
    );
  }
}
