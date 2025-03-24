class PriceEntry {
  final String id;
  final String productName;
  final String market;
  final double price;
  final String currency;
  final double quantity;
  final String unit;
  final String productType;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime date;
  final String notes;
  final String status; // 'pending', 'approved', 'rejected'
  final String category;
  
  PriceEntry({
    required this.id,
    required this.productName,
    required this.market,
    required this.price,
    this.currency = 'UGX',
    required this.quantity,
    required this.unit,
    required this.productType,
    required this.location,
    this.latitude,
    this.longitude,
    required this.date,
    required this.notes,
    required this.status,
    this.category = 'grain',
  });
  
  factory PriceEntry.fromJson(Map<String, dynamic> json) {
    return PriceEntry(
      id: json['_id'] ?? json['id'] ?? '',
      productName: json['product'] ?? json['productName'],
      market: json['market'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'UGX',
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      productType: json['productType'],
      location: json['location'] ?? json['market'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      date: DateTime.parse(json['date']),
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'pending',
      category: json['category'] ?? 'grain',
    );
  }
  
  factory PriceEntry.fromMap(Map<String, dynamic> map) {
    return PriceEntry(
      id: map['id'],
      productName: map['productName'],
      market: map['market'],
      price: map['price'],
      currency: map['currency'],
      quantity: map['quantity'],
      unit: map['unit'],
      productType: map['productType'],
      location: map['location'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
      status: map['status'],
      category: map['category'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product': productName,
      'market': market,
      'price': price,
      'currency': currency,
      'quantity': quantity,
      'unit': unit,
      'productType': productType,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'notes': notes,
      'category': category,
    };
  }
  
  PriceEntry copyWith({
    String? id,
    String? productName,
    String? market,
    double? price,
    String? currency,
    double? quantity,
    String? unit,
    String? productType,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? date,
    String? notes,
    String? status,
    String? category,
  }) {
    return PriceEntry(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      market: market ?? this.market,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      productType: productType ?? this.productType,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }
}

