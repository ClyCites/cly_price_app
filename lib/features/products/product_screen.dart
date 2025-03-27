import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/models/product.dart';
import '../../core/models/price_alert_model.dart';
import '../../core/providers/product_provider.dart';
import '../../core/providers/market_provider.dart';
import '../../core/providers/price_alert_provider.dart';
import '../../core/theme/app_colors.dart';
import '../common/widgets/loading_indicator.dart';
import '../alerts/add_alert_screen.dart';
import 'widgets/price_history_chart.dart';
import 'widgets/market_price_list.dart';
import 'widgets/product_alerts_list.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Product? _product;
  String _selectedTimeframe = 'Month';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProductData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final marketProvider = Provider.of<MarketProvider>(context, listen: false);
      final alertProvider = Provider.of<PriceAlertProvider>(context, listen: false);

      // Find the product
      final product = productProvider.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => throw Exception('Product not found'),
      );

      // Load price data
      await productProvider.fetchPriceData(product.name, _selectedTimeframe);

      // Load market comparisons
      await marketProvider.fetchMarketsByProduct(product.name);

      // Load alerts
      await alertProvider.loadAlerts();

      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product data: $e';
        _isLoading = false;
      });
    }
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });

    if (_product != null) {
      Provider.of<ProductProvider>(context, listen: false)
          .fetchPriceData(_product!.name, _selectedTimeframe);
    }
  }

  void _shareProduct() {
    if (_product == null) return;

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final currencyFormat = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);

    final shareText = '''
Check out ${_product!.name} prices on ClyCites!

Current Price: ${currencyFormat.format(productProvider.currentPrice)}
Price Change: ${productProvider.priceChangePercentage >= 0 ? '+' : ''}${productProvider.priceChangePercentage.toStringAsFixed(2)}%

Download the ClyCites app to track agricultural prices in real-time.
''';

    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: LoadingIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error Loading Product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProductData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Details')),
        body: const Center(child: Text('Product not found')),
      );
    }

    final productProvider = Provider.of<ProductProvider>(context);
    final marketProvider = Provider.of<MarketProvider>(context);
    final alertProvider = Provider.of<PriceAlertProvider>(context);
    
    final currencyFormat = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    final productAlerts = alertProvider.getAlertsForProduct(widget.productId);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(_product!.name),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _product!.imageUrl.isNotEmpty
                        ? Image.network(
                            _product!.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppColors.primary.withOpacity(0.8),
                            child: Center(
                              child: Icon(
                                Icons.agriculture,
                                size: 64,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareProduct,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_active),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddAlertScreen(
                          productId: widget.productId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            // Product Summary Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Price',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMedium,
                              ),
                            ),
                            Text(
                              currencyFormat.format(productProvider.currentPrice),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getPriceChangeColor(productProvider.priceChangePercentage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                productProvider.priceChangePercentage >= 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16,
                                color: _getPriceChangeColor(productProvider.priceChangePercentage),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${productProvider.priceChangePercentage >= 0 ? '+' : ''}${productProvider.priceChangePercentage.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: _getPriceChangeColor(productProvider.priceChangePercentage),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildInfoChip(Icons.category, 'Category: ${_product!.category}'),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.scale, 'Unit: ${_product!.defaultUnit}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMedium,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Price History'),
                Tab(text: 'Markets'),
                Tab(text: 'Alerts'),
              ],
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Price History Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Price History',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedTimeframe,
                              underline: const SizedBox(),
                              items: ['Day', 'Week', 'Month', '3 Months', 'Year'].map((timeframe) {
                                return DropdownMenuItem(
                                  value: timeframe,
                                  child: Text(timeframe),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  _onTimeframeChanged(value);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: PriceHistoryChart(
                            priceData: productProvider.priceData,
                            timeframe: _selectedTimeframe,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Markets Tab
                  MarketPriceList(
                    productName: _product!.name,
                    marketComparisons: marketProvider.marketComparisons,
                  ),
                  
                  // Alerts Tab
                  ProductAlertsList(
                    productId: widget.productId,
                    productName: _product!.name,
                    alerts: productAlerts,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAlertScreen(
                productId: widget.productId,
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textMedium,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriceChangeColor(double change) {
    if (change > 0) {
      return Colors.green;
    } else if (change < 0) {
      return Colors.red;
    }
    return Colors.orange;
  }
}

