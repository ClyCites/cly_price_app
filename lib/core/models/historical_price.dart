class HistoricalPrice {
  final DateTime date;
  final double price;

  HistoricalPrice({
    required this.date,
    required this.price,
  });

  factory HistoricalPrice.fromJson(Map<String, dynamic> json) {
    return HistoricalPrice(
      date: DateTime.parse(json['date']),
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
    };
  }
}

