import 'package:flutter/foundation.dart';

enum AlertType {
  below,
  above,
  change,
}

enum AlertFrequency {
  once,
  always,
}

class PriceAlert {
  final String id;
  final String productId;
  final String productName;
  final String? marketId;
  final String? marketName;
  final double targetPrice;
  final AlertType alertType;
  final AlertFrequency frequency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;
  final bool hasBeenTriggered;
  final String userId;

  PriceAlert({
    required this.id,
    required this.productId,
    required this.productName,
    this.marketId,
    this.marketName,
    required this.targetPrice,
    required this.alertType,
    this.frequency = AlertFrequency.once,
    this.isActive = true,
    required this.createdAt,
    this.lastTriggeredAt,
    this.hasBeenTriggered = false,
    required this.userId,
  });

  PriceAlert copyWith({
    String? id,
    String? productId,
    String? productName,
    String? marketId,
    String? marketName,
    double? targetPrice,
    AlertType? alertType,
    AlertFrequency? frequency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTriggeredAt,
    bool? hasBeenTriggered,
    String? userId,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      targetPrice: targetPrice ?? this.targetPrice,
      alertType: alertType ?? this.alertType,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      hasBeenTriggered: hasBeenTriggered ?? this.hasBeenTriggered,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'marketId': marketId,
      'marketName': marketName,
      'targetPrice': targetPrice,
      'alertType': alertType.index,
      'frequency': frequency.index,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
      'hasBeenTriggered': hasBeenTriggered,
      'userId': userId,
    };
  }

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      marketId: json['marketId'],
      marketName: json['marketName'],
      targetPrice: json['targetPrice'] != null ? double.parse(json['targetPrice'].toString()) : 0.0,
      alertType: AlertType.values[json['alertType'] ?? 0],
      frequency: AlertFrequency.values[json['frequency'] ?? 0],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      lastTriggeredAt: json['lastTriggeredAt'] != null ? DateTime.parse(json['lastTriggeredAt']) : null,
      hasBeenTriggered: json['hasBeenTriggered'] ?? false,
      userId: json['userId'] ?? '',
    );
  }

  static List<PriceAlert> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PriceAlert.fromJson(json)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceAlert &&
        other.id == id &&
        other.productId == productId &&
        other.marketId == marketId &&
        other.targetPrice == targetPrice &&
        other.alertType == alertType;
  }

  @override
  int get hashCode => id.hashCode ^ productId.hashCode ^ marketId.hashCode ^ targetPrice.hashCode ^ alertType.hashCode;

  String getAlertTypeText() {
    switch (alertType) {
      case AlertType.below:
        return 'Price falls below';
      case AlertType.above:
        return 'Price rises above';
      case AlertType.change:
        return 'Price changes by';
      default:
        return 'Unknown';
    }
  }

  String getFrequencyText() {
    switch (frequency) {
      case AlertFrequency.once:
        return 'Once';
      case AlertFrequency.always:
        return 'Always';
      default:
        return 'Unknown';
    }
  }

  String getStatusText() {
    if (!isActive) return 'Inactive';
    if (hasBeenTriggered && frequency == AlertFrequency.once) return 'Triggered';
    return 'Active';
  }
}

