import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/market_model.dart';
import '../../../core/theme/app_colors.dart';

class MarketList extends StatelessWidget {
  final List<Map<String, dynamic>> marketComparisons;
  final Function(Map<String, dynamic>) onMarketSelected;

  const MarketList({
    Key? key,
    required this.marketComparisons,
    required this.onMarketSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Responsive text sizes
    final titleSize = size.width * 0.04;
    final subtitleSize = size.width * 0.03;
    final priceSize = size.width * 0.04;
    final smallTextSize = size.width * 0.028;
    
    // Responsive spacing
    final padding = size.width * 0.04;
    final spacing = size.height * 0.015;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Prices',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacing),
            Expanded(
              child: ListView.separated(
                itemCount: marketComparisons.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final comparison = marketComparisons[index];
                  final marketData = comparison['market'];
                  
                  // Extract market name from market data
                  String marketName = 'Unknown Market';
                  if (marketData is String) {
                    marketName = marketData;
                  } else if (marketData is Map) {
                    marketName = marketData['name'] as String? ?? 'Unknown Market';
                  }
                  
                  // Ensure price is a double
                  final price = comparison['price'] is int 
                      ? (comparison['price'] as int).toDouble() 
                      : comparison['price'] as double;
                  
                  // Get trend percentage if available
                  final trendPercentage = comparison['trendPercentage'] as double? ?? 0.0;
                  
                  return InkWell(
                    onTap: () => onMarketSelected(comparison),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.012,
                        horizontal: size.width * 0.02,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  marketName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: subtitleSize * 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: size.height * 0.004),
                                Text(
                                  'Updated: ${_formatDate(comparison['date'])}',
                                  style: TextStyle(
                                    fontSize: smallTextSize,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    symbol: 'UGX ',
                                    decimalDigits: 0,
                                  ).format(price),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: priceSize,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.004),
                                _buildTrendIndicator(context, trendPercentage),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context, double trendPercentage) {
    final size = MediaQuery.of(context).size;
    final smallTextSize = size.width * 0.028;
    final iconSize = size.width * 0.035;
    
    final isPositive = trendPercentage >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: size.height * 0.004,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: iconSize,
          ),
          SizedBox(width: size.width * 0.01),
          Text(
            '${trendPercentage.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: smallTextSize,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateData) {
    if (dateData == null) return 'Unknown';
    
    try {
      final DateTime date = dateData is String 
          ? DateTime.parse(dateData) 
          : DateTime.fromMillisecondsSinceEpoch(dateData);
      
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }
}

