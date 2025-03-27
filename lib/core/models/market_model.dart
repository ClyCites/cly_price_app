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
  final String? contactInfo;
  final String? description;
  final String? imageUrl;

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
    this.contactInfo,
    this.description,
    this.imageUrl,
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
    String? contactInfo,
    String? description,
    String? imageUrl,
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
      contactInfo: contactInfo ?? this.contactInfo,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
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
      'contactInfo': contactInfo,
      'description': description,
      'imageUrl': imageUrl,
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
      contactInfo: json['contactInfo'],
      description: json['description'],
      imageUrl: json['imageUrl'],
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

