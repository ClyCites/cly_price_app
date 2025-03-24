import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/dashboard/price_chart.dart';
import '../widgets/dashboard/price_summary.dart';
import '../widgets/dashboard/trending_products.dart';
import '../widgets/common/app_drawer.dart';
import '../widgets/common/notification_badge.dart';
import 'notifications_screen.dart';
import 'data_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _selectedProduct = 'Rice';
  String _selectedTimeframe = 'Week';
  
  final List<String> _products = ['Rice', 'Wheat', 'Corn', 'Soybeans', 'Coffee'];
  final List<String> _timeframes = ['Day', 'Week', 'Month', '3 Months', 'Year'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts();
    await productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onProductChanged(String? value) {
    if (value != null && value != _selectedProduct) {
      setState(() {
        _selectedProduct = value;
      });
      
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
    }
  }

  void _onTimeframeChanged(String? value) {
    if (value != null && value != _selectedTimeframe) {
      setState(() {
        _selectedTimeframe = value;
      });
      
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClyCites Dashboard'),
        actions: [
          NotificationBadge(
            count: notificationProvider.unreadCount,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Analytics',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Product',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedProduct,
                                    items: _products.map((product) {
                                      return DropdownMenuItem(
                                        value: product,
                                        child: Text(product),
                                      );
                                    }).toList(),
                                    onChanged: _onProductChanged,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'Timeframe',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _selectedTimeframe,
                                    items: _timeframes.map((timeframe) {
                                      return DropdownMenuItem(
                                        value: timeframe,
                                        child: Text(timeframe),
                                      );
                                    }).toList(),
                                    onChanged: _onTimeframeChanged,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            PriceChart(
                              priceData: productProvider.priceData,
                              product: _selectedProduct,
                              timeframe: _selectedTimeframe,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PriceSummary(
                      product: _selectedProduct,
                      currentPrice: productProvider.currentPrice,
                      priceChange: productProvider.priceChange,
                      priceChangePercentage: productProvider.priceChangePercentage,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Trending Products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TrendingProducts(
                      products: productProvider.trendingProducts,
                      onProductSelected: (product) {
                        setState(() {
                          _selectedProduct = product;
                        });
                        productProvider.fetchPriceData(_selectedProduct, _selectedTimeframe);
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataEntryScreen()),
          );
        },
        tooltip: 'Add Price Data',
        child: const Icon(Icons.add),
      ),
    );
  }
}

