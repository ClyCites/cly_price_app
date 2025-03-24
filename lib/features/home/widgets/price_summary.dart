import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class PriceSummary extends StatelessWidget {
  final String product;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercentage;

  const PriceSummary({
    super.key,
    required this.product,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercentage,
  });

  @override
  Widget build(BuildContext context) {
    final isPositiveChange = priceChange >= 0;
    final changeColor = isPositiveChange ? AppColors.success : AppColors.error;
    final changeIcon = isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Current Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    symbol: 'UGX ',
                    decimalDigits: 0,
                  ).format(currentPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Price Change
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  changeIcon,
                  color: changeColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${priceChangePercentage.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

