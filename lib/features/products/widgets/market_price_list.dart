import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class MarketPriceList extends StatelessWidget {
  final String productName;
  final List<Map<String, dynamic>> marketComparisons;

  const MarketPriceList({
    Key? key,
    required this.productName,
    required this.marketComparisons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (marketComparisons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No market data available',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Sort comparisons by price (lowest first)
    final sortedComparisons = List<Map<String, dynamic>>.from(marketComparisons)
      ..sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));

    // Calculate average price
    double totalPrice = 0;
    for (final comparison in marketComparisons) {
      totalPrice += comparison['price'] as double;
    }
    final avgPrice = totalPrice / marketComparisons.length;

    return Column(
      children: [
        // Average price card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calculate,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Price',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMedium,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: 'UGX ',
                          decimalDigits: 0,
                        ).format(avgPrice),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Across ${marketComparisons.length} markets',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Market list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedComparisons.length,
            itemBuilder: (context, index) {
              final comparison = sortedComparisons[index];
              final market = comparison['market'] as String;
              final price = comparison['price'] as double;
              final date = comparison['date'] != null
                  ? DateTime.parse(comparison['date'] as String)
                  : DateTime.now();
              
              // Calculate price difference from average
              final difference = price - avgPrice;
              final percentDifference = avgPrice != 0 ? (difference / avgPrice) * 100 : 0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getPriceColor(percentDifference.toDouble()).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPriceColor(percentDifference.toDouble()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              market,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Updated: ${DateFormat('MMM d, yyyy').format(date)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(
                              symbol: 'UGX ',
                              decimalDigits: 0,
                            ).format(price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriceColor(percentDifference.toDouble()).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDifference(percentDifference.toDouble()),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getPriceColor(percentDifference.toDouble()),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getPriceColor(double percentDifference) {
    if (percentDifference < -5) {
      return Colors.green;
    } else if (percentDifference > 5) {
      return Colors.red;
    }
    return Colors.orange;
  }

  String _formatDifference(double percentDifference) {
    final sign = percentDifference >= 0 ? '+' : '';
    return '$sign${percentDifference.toStringAsFixed(1)}%';
  }
}

