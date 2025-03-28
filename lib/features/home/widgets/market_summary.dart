import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/market_provider.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/theme/app_colors.dart';

class MarketSummary extends StatefulWidget {
  final String productId;
  final String productName;

  const MarketSummary({
    Key? key,
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<MarketSummary> createState() => _MarketSummaryState();
}

class _MarketSummaryState extends State<MarketSummary> {
  @override
  void initState() {
    super.initState();
    if (widget.productId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final marketProvider = Provider.of<MarketProvider>(context, listen: false);
        marketProvider.fetchMarketsByProductId(widget.productId);
      });
    }
  }

  @override
  void didUpdateWidget(MarketSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fetch market data when product changes
    if (oldWidget.productId != widget.productId && widget.productId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final marketProvider = Provider.of<MarketProvider>(context, listen: false);
        marketProvider.fetchMarketsByProductId(widget.productId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't attempt to fetch data if product ID is empty
    if (widget.productId.isEmpty) {
      return _buildEmptyState(context);
    }

    final marketProvider = Provider.of<MarketProvider>(context);
    
    if (marketProvider.isLoading) {
      return _buildLoadingState();
    }
    
    if (marketProvider.hasError) {
      return _buildErrorState(context, marketProvider.errorMessage ?? 'Failed to load market data');
    }
    
    // Ensure we have market data for this product
    if (marketProvider.marketComparisons.isEmpty) {
      // Fetch market data if not already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        marketProvider.fetchMarketsByProductId(widget.productId);
      });
      return _buildLoadingState();
    }
    
    final cheapestMarket = marketProvider.findCheapestMarket(widget.productId);
    final expensiveMarket = marketProvider.findMostExpensiveMarket(widget.productId);
    final avgPrice = marketProvider.getAveragePrice(widget.productId);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/markets');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Average price
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.attach_money,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Price',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: 'UGX ',
                          decimalDigits: 0,
                        ).format(avgPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.productName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Cheapest and most expensive markets
            Row(
              children: [
                // Cheapest market
                Expanded(
                  child: _MarketPriceCard(
                    title: 'Cheapest',
                    marketName: cheapestMarket?.name ?? 'N/A',
                    price: cheapestMarket?.currentPrice ?? 0,
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Most expensive market
                Expanded(
                  child: _MarketPriceCard(
                    title: 'Most Expensive',
                    marketName: expensiveMarket?.name ?? 'N/A',
                    price: expensiveMarket?.currentPrice ?? 0,
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Market count and last updated
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${marketProvider.marketComparisons.length} markets available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Last updated: ${_formatDate(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Market Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Loading indicator
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading market data...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Error message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load market data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
                      marketProvider.fetchMarketsByProductId(widget.productId);
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Product Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please select a product to view market data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MarketPriceCard extends StatelessWidget {
  final String title;
  final String marketName;
  final double price;
  final IconData icon;
  final Color iconColor;

  const _MarketPriceCard({
    Key? key,
    required this.title,
    required this.marketName,
    required this.price,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            marketName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              symbol: 'UGX ',
              decimalDigits: 0,
            ).format(price),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

